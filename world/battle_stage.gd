extends Node2D

signal finalize_turn
signal new_turn
signal unit_added(unit:Unit)
signal battle_over(winner:StringName)

## Free fallback technique for units with no charges left, so battles can't stall.
const STRUGGLE_TECHNIQUE:String = "res://data/battletechnique_struggle.tres"

var enemy_team:TeamDef
var player_team:TeamDef
@export var background_music:AudioStream
static var battle_unit:PackedScene = load("uid://bm03ut2gnfrq8")

var turn_ready:bool = false
var turn_index:int = 0
var executing_turn:bool = false
# TODO: have this tracked by team entities such as the player entity.
var units_player:Dictionary[Unit,CombatMechanics.UnitStatus]
var units_enemy:Dictionary[Unit,CombatMechanics.UnitStatus]
var winner:StringName=&""


func _ready():
	if background_music:
		GameManager.play_music(background_music)
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func begin_player_battle(opponent:OverworldAgent):
	%PlayerBattlefield.reset_map() # Reset occupancy maps.
	%EnemyBattlefield.reset_map()
	units_player.clear()
	units_enemy.clear()
	winner = &""
	turn_index = 0
	executing_turn = false
	process_mode = PROCESS_MODE_INHERIT
	$Camera2D.make_current()
	visible=true
	var player:OverworldPlayer = get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY)
	if player:
		var player_units:Array[Unit] = player.get_battle_units()
		deploy_team(player_units, player_units.size(), Constants.PLAYER_GROUP)
	deploy_team(opponent.units, opponent.initial_deploy, Constants.ENEMY_GROUP)
	await get_tree().physics_frame
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")
	start_turn()

## Deploys up to max_deploy units that are able to fight onto the given side.
func deploy_team(units:Array[Unit], max_deploy:int, side:StringName):
	var target_side:Battlefield = %PlayerBattlefield if side==Constants.PLAYER_GROUP else %EnemyBattlefield
	var centre_file:int = ceili(target_side.dimensions.x/2)
	var deployed:int = 0
	for unit:Unit in units:
		if deployed >= max_deploy:
			break
		if unit.hp <= 0: # If they're able to fight, deploy, else skip them. Later, replace this with querying the team Behaviour tree?
			continue
		var unit_position:Vector2i = Vector2i(centre_file,unit.unit_definition.default_desired_rank) # Default put 'em in the centre for now.
		if target_side.is_tile_occupied(unit_position.x,unit_position.y): # if the position is occupied, find the next free.
			unit_position = target_side.get_next_free_bit(unit.unit_definition.default_desired_rank)
		if unit_position.x < 0: # Battlefield is full.
			break
		add_unit(unit,unit_position,side)
		deployed += 1

func add_unit(unit:Unit,unit_position:Vector2i,side:StringName=Constants.ENEMY_GROUP):
	var target_side:Battlefield = %PlayerBattlefield if side==Constants.PLAYER_GROUP else %EnemyBattlefield
	target_side.add_child(unit)
	unit.global_position = target_side.get_tile_center_global_position(unit_position.x,unit_position.y)
	unit.reset_physics_interpolation()
	new_turn.connect(unit.on_new_turn)
	finalize_turn.connect(unit.on_finalize_turn)
	target_side.set_tile_occupied(unit_position.x,unit_position.y,true)
	var roster:Dictionary[Unit,CombatMechanics.UnitStatus] = units_player if side==Constants.PLAYER_GROUP else units_enemy
	roster[unit] = CombatMechanics.UnitStatus.ACTIVE
	unit_added.emit(unit)
	return unit

#region Turns

## Clears last turn's actions and has the enemy pick theirs. The player then assigns actions before calling execute_turn().
func start_turn():
	turn_index += 1
	new_turn.emit()
	assign_enemy_actions()
	assign_struggle_actions()

## Placeholder enemy AI until team behaviour trees drive this: use the first technique with charges left on a random active player unit.
func assign_enemy_actions():
	var targets:Array[Unit] = get_active_units(units_player)
	if targets.is_empty():
		return
	for unit:Unit in get_active_units(units_enemy):
		var uses:Dictionary = unit.get_technique_uses()
		for tech:BattleTechnique in unit.base_techniques:
			if uses.get(tech,0) > 0 and unit.queue_technique(tech):
				if tech.valid_target & CombatMechanics.TargetTypes.ENEMY:
					unit.next_action.target = targets.pick_random()
				else:
					unit.next_action.target = unit
				break

## Units on either side with no charges left for any technique struggle against a random foe.
func assign_struggle_actions():
	var struggle:BattleTechnique = load(STRUGGLE_TECHNIQUE)
	for side:Array in [[units_player, units_enemy], [units_enemy, units_player]]:
		var foes:Array[Unit] = get_active_units(side[1])
		if foes.is_empty():
			continue
		for unit:Unit in get_active_units(side[0]):
			if not unit.can_act():
				unit.next_action = Unit.TurnAction.new(unit, struggle)
				unit.next_action.target = foes.pick_random()
				unit.update.emit()

## Executes every active unit's assigned action, fastest first. Returns false if the turn couldn't run because a player unit has no action.
func execute_turn() -> bool:
	if executing_turn or winner:
		return false
	turn_ready = get_active_units(units_player).all(func(unit:Unit): return unit.has_action())
	finalize_turn.emit() # Units raise their own alerts for missing actions.
	if not turn_ready:
		return false
	executing_turn = true
	for unit:Unit in get_turn_order():
		if unit.hp <= 0: # Knocked out earlier this turn.
			continue
		execute_action(unit.next_action)
		if check_battle_over():
			executing_turn = false
			return true
	for unit:Unit in get_all_active_units():
		CombatMechanics.process_unit_effects(turn_index, unit)
	executing_turn = false
	if not check_battle_over():
		start_turn()
	return true

## Active units from both sides sorted by speed, highest first. Ties are broken randomly.
func get_turn_order() -> Array[Unit]:
	var order:Array[Unit] = get_all_active_units()
	var tie_break:Dictionary[Unit,float] = {}
	for unit:Unit in order:
		tie_break[unit] = randf()
	order.sort_custom(func(a:Unit, b:Unit):
		if a.speed == b.speed:
			return tie_break[a] > tie_break[b]
		return a.speed > b.speed
	)
	return order

func execute_action(action:Unit.TurnAction):
	var ctx:CombatMechanics.Context = action.create_context()
	if action.target is Unit:
		ctx.target_units.assign(ctx.target_units.filter(func(target:Unit): return target.hp > 0))
		if ctx.target_units.is_empty(): # Target was knocked out before this unit acted.
			print_debug("%s's %s had no target" % [action.owner.display_name, action.technique.technique_name])
			return
	action.technique.activate(ctx)
	action.complete_turn()

func get_active_units(units:Dictionary[Unit,CombatMechanics.UnitStatus]) -> Array[Unit]:
	var active:Array[Unit] = []
	for unit:Unit in units.keys():
		if units[unit] == CombatMechanics.UnitStatus.ACTIVE:
			active.append(unit)
	return active

func get_all_active_units() -> Array[Unit]:
	var active:Array[Unit] = get_active_units(units_player)
	active.append_array(get_active_units(units_enemy))
	return active

#endregion

## Updates unit statuses, returns true if any unit on the side is still active.
func check_unit_status(units:Dictionary[Unit,CombatMechanics.UnitStatus]):
	for unit:Unit in units.keys():
		if unit.hp <= 0:
			units[unit] = CombatMechanics.UnitStatus.INCAP
	return units.values().any(
		func(value:CombatMechanics.UnitStatus):
			return value == CombatMechanics.UnitStatus.ACTIVE
	)

## Ends the battle if either side has no active units left. The player loses if both sides go down together.
func check_battle_over() -> bool:
	var player_active:bool = check_unit_status(units_player)
	var enemy_active:bool = check_unit_status(units_enemy)
	if player_active and enemy_active:
		return false
	battle_end(Constants.PLAYER_GROUP if player_active else Constants.ENEMY_GROUP)
	return true

func battle_end(battle_winner:StringName):
	winner = battle_winner
	visible = false
	$Camera2D.enabled = false
	%PlayerBattlefield.reset_map() # Units go back to their owning teams.
	%EnemyBattlefield.reset_map()
	process_mode = PROCESS_MODE_DISABLED
	battle_over.emit(winner)
