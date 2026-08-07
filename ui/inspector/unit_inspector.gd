extends Control

const BLANK_STAT:String = "-"

const STAT_TEMPLATE:String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n"
const POSITIVE_MOD:String = "[color=green](+%s)[/color]"
const NEGATIVE_MOD:String = "[color=red](%s)[/color]"


func load_unit(unit:Unit):
	%Name.text = unit.display_name
	%Subtitle.text = unit.subtitle
	# TODO: Types display
	%AbilityTitle.text = unit.ability.ability_name
	%AbilityDescription.text = unit.ability.ability_description
	%Portrait.texture = unit.unit_definition.portrait
	%AttributeBaseLabel.text = STAT_TEMPLATE % unit.attribute_base
	%AttributeBonusLabel.text = STAT_TEMPLATE % unit.attribute_bonus
	%AttributeModifierlabel.text = get_unit_modifiers(unit)
	%AttributeTotalLabel.text = STAT_TEMPLATE % [unit.hp,unit.attack,unit.defense,unit.special_attack,unit.special_defense,unit.speed,unit.size]
	%DescriptionLabel.text = unit.unit_definition.description
	list_unit_techniques(unit)
	list_unit_equipment(unit)


func get_unit_modifiers(unit:Unit) -> String:
	var mod_array:Array[String] = ["","","","","","",""]
	for i:int in range(mod_array.size()):
		if unit.attribute_modifier[i] > 0:
			mod_array[i] = POSITIVE_MOD % (CombatMechanics.calc_attribute(unit.attribute_base[i],unit.attribute_modifier[i])-unit.attribute_base[i])
		if unit.attribute_modifier[i] < 0:
			mod_array[i] = NEGATIVE_MOD % (CombatMechanics.calc_attribute(unit.attribute_base[i],unit.attribute_modifier[i])-unit.attribute_base[i])
	return "\n".join(mod_array)

#TODO: Make popups/tooltips for the unit equipment when clicked or mouseover.
func list_unit_equipment(unit:Unit) -> void:
	%EquipmentList.clear()
	for item:EquipItem in unit.equipped_items:
		%EquipmentList.add_item(item.display_name)
		if item.granted_techniques.size():
			for tech:BattleTechnique in item.granted_techniques:
				var display_name:String = tech.display_name if tech.display_name != "" else tech.technique_name.capitalize()
				%TechniquesList.add_item(display_name)
		
#TODO: Make popups/tooltips for the unit techniques when clicked or mouseover.
func list_unit_techniques(unit:Unit):
	%TechniquesList.clear()
	for tech:BattleTechnique in unit.base_techniques:
		# Get the display name, or if blank convert the technique's name to a nice format.
		var display_name:String = tech.display_name if tech.display_name != "" else tech.technique_name.capitalize()
		%TechniquesList.add_item(display_name)
