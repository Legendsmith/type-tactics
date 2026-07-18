extends Node

signal finalize_turn
signal new_turn
signal unit_added(unit:Unit)

@export_custom(0,"scene") var interface_scene:String

static var battle_unit:PackedScene = load("uid://bm03ut2gnfrq8")

var turn_ready:bool = false

var units_player:Dictionary[Unit,CombatMechanics.UnitStatus]
var units_enemy:Dictionary[Unit,CombatMechanics.UnitStatus]



func _ready():
	configure_interface()
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func configure_interface():
	var interface:Control = load(interface_scene).instantiate()
	GameManager.game_interface = interface
	GameManager.add_child(interface)

func deploy_team(team:TeamDef):
	var side = team.control

	for i:int in range(team.units.size()):
		var unitdef:UnitDef = team.units[i]
		var new_unit:Unit = battle_unit.instantiate()
		new_unit.control_type = team.control
		add_unit(new_unit,team.deployment[i],side)
		new_unit.create_from_unit_def(unitdef)
		new_unit.equipped_items=unitdef.equipment
		new_unit.battle_setup()



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
