extends Node

signal finalize_turn
signal new_turn
signal unit_added(unit:Unit)

@export_custom(0,"scene") var interface_scene:String

var turn_ready:bool = false

func _ready():
	configure_interface()
	get_tree().call_group(Unit.UNIT_GROUP,&"battle_setup")

func configure_interface():
	var interface:Control = load(interface_scene).instantiate()
	GameManager.game_interface = interface
	GameManager.add_child(interface)


func add_unit(unit:Unit,unit_position:Vector2i,side:int=CombatMechanics.Side.ENEMY):
	var target_side:Battlefield = %PlayerBattlefield if side else %EnemyBattlefield
	target_side.add_child(unit)
	unit.global_position = target_side.get_tile_center_global_position(unit_position.x,unit_position.y)
	unit.reset_physics_interpolation()
	new_turn.connect(unit.on_new_turn)
	finalize_turn.connect(unit.on_finalize_turn)
	unit_added.emit(unit)
