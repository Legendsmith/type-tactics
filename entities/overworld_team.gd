extends OverworldAgent

@export var team: TeamDef

func _ready() -> void:
	calculate_overworld_power()
	super()


func calculate_overworld_power():
	overworld_atk = 0
	overworld_def = 0
	var hp: int = 0
	for unit: UnitDef in team.units:
		hp += unit.attribute_base[Unit.Attribute.HP]
	max_overworld_hp = hp
	for unit: UnitDef in team.units:
		overworld_atk += unit.attribute_base[Unit.Attribute.ATTACK] + unit.attribute_base[Unit.Attribute.SPECIAL_ATTACK]
		overworld_def += unit.attribute_base[Unit.Attribute.DEFENSE] + unit.attribute_base[Unit.Attribute.SPECIAL_DEFENSE]

