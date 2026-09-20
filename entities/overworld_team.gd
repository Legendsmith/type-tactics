@tool
extends OverworldAgent

@export var team: TeamDef
@export var units:Array[Unit] = []
@export var initial_deploy:int = 3
func _ready() -> void:
	#calculate_overworld_attributes()
	super()


func calculate_overworld_attributes():
	overworld_atk = 0
	overworld_def = 0
	var hp: int = 0
	for unit: UnitDef in team.units:
		hp += unit.attribute_base[Unit.Attribute.HP]
	max_overworld_hp = hp
	for unit: UnitDef in team.units:
		overworld_atk += unit.attribute_base[Unit.Attribute.ATTACK] + unit.attribute_base[Unit.Attribute.SPECIAL_ATTACK]
		overworld_def += unit.attribute_base[Unit.Attribute.DEFENSE] + unit.attribute_base[Unit.Attribute.SPECIAL_DEFENSE]

func on_interact():
	if not Dialogic.current_timeline:
		Dialogic.start(dialogic_timeline,dialogic_timeline_label)
		await Dialogic.timeline_ended
		if dialogic_timeline_label == Constants.DIALOG_BATTLE_BEGIN:
			freeze=true
			begin_battle()

func init_team():
	units.resize(team.units.size())
	var unit_scene:PackedScene = load(Unit.battle_unit_scene)
	for i:int in range(team.units.size()):
		var unitdef:UnitDef = team.units[i]
		var new_unit:Unit = unit_scene.instantiate()
		new_unit.control_type = team.control
		new_unit.create_from_unit_def(unitdef)
		new_unit.equipped_items=unitdef.equipment
		units[i] = new_unit
			


func begin_battle():
	if units.size() == 0: # Initialize our team if we haven't yet.
		init_team()
	var battle_stage:Node2D = get_tree().current_scene.begin_player_battle(self)
	await battle_stage.battle_over
	if battle_stage.winner == Constants.PLAYER_GROUP:
		Dialogic.start(dialogic_timeline,Constants.DIALOG_BATTLE_VICTORY)
	elif battle_stage.winner == Constants.ENEMY_GROUP:
		Dialogic.start(dialogic_timeline,Constants.DIALOG_BATTLE_DEFEAT)
	freeze=false
	dialogic_timeline_label=Constants.DIALOG_REPEAT
