extends MainScene2D

signal finalize_turn
signal new_turn
signal unit_added(unit:Unit)
signal battle_over(winner:StringName)

var enemy_team:TeamDef
var player_team:TeamDef

var turn_ready:bool = false
# TODO: have this tracked by team entities such as the player entity.
var units_player:Dictionary[Unit,CombatMechanics.UnitStatus]
var units_enemy:Dictionary[Unit,CombatMechanics.UnitStatus]
var winner:StringName=&""


func _ready():
	super()
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func begin_player_battle(opponent:OverworldAgent):
	%EnemyBattlefield.reset_map() # Reset occupancy map.
	var centre_file:int = ceili(%EnemyBattlefield.dimensions.x/2)
	var num_to_deploy:int = min(opponent.initial_deploy,opponent.units.size())
	for i:int in range(num_to_deploy):
		var unit:Unit = opponent.units[i]
		if unit.hp > 0: # If they're able to fight, deploy, else skip them. Later, replace this with querying the team Behaviour tree?
			var unit_position:Vector2i = Vector2i(centre_file,unit.unit_definition.default_desired_rank) # Default put 'em in the centre for now.
			if %EnemyBattlefield.is_tile_occupied(centre_file,unit.unit_definition.default_desired_rank): # if the position is occupied, find the next free.
				unit_position = %EnemyBattlefield.get_next_free_bit(unit.unit_definition.default_desired_rank)
			add_unit(unit,unit_position, Constants.ENEMY_GROUP)
	await get_tree().physics_frame
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func add_unit(unit:Unit,unit_position:Vector2i,side:StringName=Constants.ENEMY_GROUP):
	var target_side:Battlefield = %PlayerBattlefield if side==Constants.PLAYER_GROUP else %EnemyBattlefield
	target_side.add_child(unit)
	unit.global_position = target_side.get_tile_center_global_position(unit_position.x,unit_position.y)
	unit.reset_physics_interpolation()
	new_turn.connect(unit.on_new_turn)
	finalize_turn.connect(unit.on_finalize_turn)
	target_side.set_tile_occupied(unit_position.x,unit_position.y,true)
	unit_added.emit(unit)
	return unit

func check_unit_status(units:Dictionary[Unit,CombatMechanics.UnitStatus]):
	for unit:Unit in units.keys():
		if unit.hp <= 0:
			units[unit] = CombatMechanics.UnitStatus.INCAP
	return units.values().any(
		func(value:CombatMechanics.UnitStatus):
			return value == CombatMechanics.UnitStatus.ACTIVE
	)

func battle_end():
	winner = Constants.PLAYER_GROUP
	visible = false
	%EnemyBattlefield.reset() # Reset the enemy side.
	process_mode = PROCESS_MODE_DISABLED
	battle_over.emit(winner)
