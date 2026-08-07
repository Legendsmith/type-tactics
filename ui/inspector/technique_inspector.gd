extends VBoxContainer
func load_technique(tech:BattleTechnique):
	%PowerLabel.text = "POWER: %s" % str(tech.power)
	%DescriptionLabel.text = tech.description
