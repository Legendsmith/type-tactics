extends Control

const BLANK_STAT:String = "-"

const STAT_TEMPLATE:String = "%s\n%s\n%s\n%s\n%s\n%s\n%s\n"

func load_unit(unit:Unit):
	%Name.text = unit.display_name
	%Subtitle.text = unit.subtitle
	# TODO: Types display
	%AbilityTitle.text = unit.ability.ability_name
	%AbilityDescription.text = unit.ability.ability_description

