@tool
extends Node
signal request_generate
signal request_save
@export var generate:bool = false:
	set(new):
		generate = new
		if generate:
			request_generate.emit()
@export var save:bool = false:
	set(new):
		save = new
		if save:
			request_save.emit()

const SAVE_DIRECTORY = "res://data"
@export var name_list:Dictionary[String,Texture2D]
@export var generated_resources:Array[UnitDef]


func _ready() -> void:
	name = "UnitDefGenerator"
	request_generate.connect(_on_request_generate)
	request_save.connect(save_generated_resources)

func _on_request_generate():
	if generate:
		generate_names_from_overworld_sprites()
		generate_unit_defs_from_names()
		generate = false

func generate_names_from_overworld_sprites() -> void:
	var dir = DirAccess.open("res://texture")
	var skipped_names:Array[String]
	if dir:
		var files:PackedStringArray = dir.get_files()
		for file_name:String in files:
			if file_name.contains("overworld.png") and not file_name.contains("import"):
				var split:PackedStringArray = file_name.split("_")
				var unit_name:String = split[0]
				var texture:Texture2D = load("res://texture".path_join(file_name))
				var resource_name:String = "unitdef_%s.tres" % unit_name
				var file_path:String = SAVE_DIRECTORY.path_join(resource_name)
				if FileAccess.file_exists(file_path):
					skipped_names.append(unit_name)
				else:
					name_list[unit_name] = texture
	if skipped_names.size():
		print("Skipped existing definitions:" + ", ".join(skipped_names))

func generate_unit_defs_from_names():
	for unit_name:String in name_list.keys():
		if FileAccess.file_exists(SAVE_DIRECTORY.path_join("unitdef_%s.tres" % unit_name)):
			continue
		var unit:UnitDef = UnitDef.new()
		unit.display_name = unit_name.capitalize()
		unit.unit_name = unit_name
		unit.twitch_name = unit_name
		unit.overworld_sprite = name_list[unit_name]
		unit.resource_name = unit_name
		generated_resources.append(unit)


func save_generated_resources():
	print_debug("Saving Generated resources")
	var skipped_names:Array[String]
	if save:
		for resource:UnitDef in generated_resources:
			var filename:String = "unitdef_%s.tres" % resource.unit_name
			var file_path:String = SAVE_DIRECTORY.path_join(filename)
			if FileAccess.file_exists(file_path):
				skipped_names.append(filename)
				continue
			var err = ResourceSaver.save(resource, file_path)
			if err == OK:
				print("Saved: ", file_path)
		save = false
	if skipped_names.size():
		print("Skipped existing Definitions:" + ", ".join(skipped_names))


