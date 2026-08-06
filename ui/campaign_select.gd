extends Control

@export_custom(0,"scene") var campaign_overworld_scene:String = "uid://ijvsnyqbif14"
## The scene to go to when the back button is pressed.
@export_custom(0,"scene") var back_scene:String = "uid://dea4j22alycht"
@export var button_disabled_extra_text:String = "(Coming Soon)"
@export var btn_material_normal:CanvasItemMaterial = load("uid://ctpabk6eorw2s")
@export var btn_material_pressed:CanvasItemMaterial = load("uid://cgfk3rtdq4y3d")
func _ready() -> void:
	%BackButton.pressed.connect(
		GameManager.change_scene.bind(back_scene,"instant")
	)
	# Main Campaigns
	for container:FoldableContainer in %AccordionContainer.get_children():
		container.folding_changed.connect(on_accordion_folding.bind(container).unbind(1))
		if container.folded:
			container.add_theme_font_size_override(&"font_size",24)
	
	for button:Button in %CampaignButtonGrid.get_children():
		configure_accordion_button(button,%ChooseYourCampaign)

	# Extras
	for button:Button in %ExtrasButtonGrid.get_children():
		configure_accordion_button(button,%Extras)


func on_button_down(button:Button):
	button.material = btn_material_pressed

func on_button_up(button:Button):
	button.material = btn_material_normal

func on_button_mouse_enter(button:Button,title_node:FoldableContainer):
	if button.disabled:
		title_node.title = button.name.substr(6).to_upper()+" "+button_disabled_extra_text
	else:
		title_node.title = button.name.substr(6).to_snake_case().capitalize().to_upper()


func configure_accordion_button(button:Button,title_node:FoldableContainer):
	button.mouse_entered.connect(on_button_mouse_enter.bind(button,title_node))
	button.pressed.connect(campaign_button_pressed.bind(button))
	button.material = btn_material_normal
	button.button_down.connect(on_button_down.bind(button))
	button.button_up.connect(on_button_up.bind(button))


func campaign_button_pressed(button:Button):
	var extra_data:Dictionary[StringName,Variant]
	for key:StringName in button.get_meta_list():
		extra_data[key] = button.get_meta(key)
	GameManager.change_scene(campaign_overworld_scene,"fade",true,extra_data)

func on_accordion_folding(calling_container:FoldableContainer):
	var group_containers:Array[FoldableContainer] = calling_container.foldable_group.get_containers()
	var expanded:FoldableContainer = calling_container.foldable_group.get_expanded_container()
	print_debug(group_containers)
	for container:FoldableContainer in group_containers:
		if container == expanded:
			container.foldable_group.get_expanded_container().remove_theme_font_size_override(&"font_size")
			container.size_flags_vertical = Control.SIZE_EXPAND_FILL
			continue
		container.size_flags_vertical = Control.SIZE_FILL
		container.title = container.name.to_snake_case().capitalize()
		container.add_theme_font_size_override(&"font_size",24)
