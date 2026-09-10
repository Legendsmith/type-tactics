@tool
extends OverworldAgent

@export var team: TeamDef

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
	Dialogic.start(dialogic_timeline,dialogic_timeline_label)
	await Dialogic.timeline_ended
	if dialogic_timeline_label == Constants.DIALOG_BATTLE_BEGIN:
		begin_battle()

func begin_battle():
	get_tree().current_scene.player_battle(self)
