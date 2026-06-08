@tool
extends Node

var database: UCDatabase

var _save_timer: Timer


func _init() -> void:
	_save_timer = Timer.new()
	_save_timer.autostart = false
	_save_timer.ignore_time_scale = true
	_save_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_save_timer.one_shot = true
	_save_timer.wait_time = 1.0
	_save_timer.timeout.connect(save_database_info)
	
	add_child(_save_timer, false, Node.INTERNAL_MODE_BACK)


func _enter_tree() -> void:
	var script := get_script() as Script
	assert(script)
	
	var db_path : String = script.resource_path.get_base_dir().path_join("uc_database.tres")
	
	if ResourceLoader.exists(db_path):
		database = ResourceLoader.load(db_path, "UCDatabase") as UCDatabase
		assert(database)
	else:
		database = UCDatabase.new()
		database.resource_path = db_path
		ResourceSaver.save(database)


func save_database_info() -> void:
	ResourceSaver.save(database)


func mark_dirty() -> void:
	_save_timer.start()
