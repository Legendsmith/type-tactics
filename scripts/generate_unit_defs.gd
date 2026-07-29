@tool
extends Node
@export var save:bool = false
const SAVE_DIRECTORY = "res://data"
@export var name_list:Dictionary[String,Texture2D]
@export var generated_resources:Array[UnitDef]

func _ready() -> void:
	generate_names_from_overworld_sprites()
	generate_unit_defs_from_names()
	save_generated_resources()

func generate_names_from_overworld_sprites():
	var dir = DirAccess.open("res://texture")
	if dir:
		var files:PackedStringArray = dir.get_files()
		for file_name:String in files:
			if file_name.contains("overworld.png") and not file_name.contains("import"):
				var split:PackedStringArray = file_name.split("_")
				var unit_name:String = split[0]
				var texture:Texture2D = load("res://texture".path_join(file_name))
				name_list[unit_name] = texture

func generate_unit_defs_from_names():
	for unit_name:String in name_list.keys():
		if FileAccess.file_exists(SAVE_DIRECTORY.path_join("unitdef_%s.tres" % unit_name)):
			continue
		var unit:UnitDef = UnitDef.new()
		unit.unit_name = unit_name.capitalize()
		unit.twitch_name = unit_name
		unit.overworld_sprite = name_list[unit_name]
		generated_resources.append(unit)


func save_generated_resources():
	print_debug("Saving Generated resources")
	if save:
		for resource:UnitDef in generated_resources:
			var filename:String = "unitdef_%s.tres" % resource.twitch_name
			var file_path:String = SAVE_DIRECTORY.path_join(filename)
			if FileAccess.file_exists(file_path):
				continue
			var err = ResourceSaver.save(resource, file_path)
			if err == OK:
				print("Saved: ", file_path)
		save = false


