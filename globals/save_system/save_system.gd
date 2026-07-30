extends Node

## The root path for where the saves are located.
const SAVE_ROOT: String = "user://"
const SAVE_FOLDER: String = "saves"
const _LATEST_SAVE_FILE: String = ".latest_save"
const DEFAULT_SAVE_NAME: String = "save"

## The signal that requests data from the listeners. All info set in the data dictionary must be a native type (must not inherrit from [Object]).
## In case you want to add an object, transform it into a dictionary instead, for example with [method SaveUtils.serialize_to_dictionary]
signal save_requested(data: Dictionary)

## The signal that delivers data stored on disk to the listeners.
signal load_requested(data: Dictionary)

## The signal indicating that saving has been completed successfully
signal save_completed

## The signal indicating that saving has been completed successfully
signal load_completed


## The name of the latest save that has been loaded or saved to.
var latest_save: String

## The persistent data that is being tracked for saving and loading.
var save_data: Dictionary

## Flag to enable or disable quick saving dynamically.
var quick_save_enabled: bool = true


func _ready() -> void:
	# If file doesn't exist, it will return an empty string, so not worth checking if it exists.
	var lsf: String = FileAccess.get_file_as_string(SAVE_ROOT.path_join(_LATEST_SAVE_FILE))
	if FileAccess.file_exists(save_name_to_file_path(lsf)):
		latest_save = lsf


## Gets all save file names that are currently being stored.
func get_save_file_names() -> PackedStringArray:
	# does a primitive return of all files
	return DirAccess.get_files_at(SAVE_ROOT.path_join(SAVE_FOLDER))


## Sets the latest save name and stores it locally
func set_latest_save(save_name: String) -> void:
	latest_save = save_name
	var latest_file := FileAccess.open(SAVE_ROOT.path_join(_LATEST_SAVE_FILE), FileAccess.WRITE)
	latest_file.store_string(save_name)
	latest_file.close()


## Save the game's state to the latest save name.
func save_latest() -> Error:
	assert(not latest_save.is_empty(), "Can't save to an empty save name.")
	return save_game(latest_save)


## Triggers a save procedure that gathers data from it's listeners, the data will then be stored on disk.
func save_game(save_name: String = DEFAULT_SAVE_NAME) -> Error:
	# ensure the directory for saves exists.
	DirAccess.make_dir_recursive_absolute(SAVE_ROOT.path_join(SAVE_FOLDER))
	
	# Collect data from listeners
	save_requested.emit(save_data)
	
	# Create new file 
	var temporary_location: String = SAVE_ROOT.path_join(SAVE_FOLDER).path_join("%x" % Time.get_ticks_usec() + ".tmp")
	var save_file: FileAccess = FileAccess.open(temporary_location, FileAccess.WRITE)
	if save_file == null:
		# If file creation fails, return the error for handling.
		return FileAccess.get_open_error()
	
	# Write dictionary to save file
	save_file.store_var(save_data, false)
	
	save_file.close()
	@warning_ignore(&"int_as_enum_without_cast")
	var error: int = DirAccess.rename_absolute(temporary_location, SAVE_ROOT.path_join(SAVE_FOLDER).path_join(save_name))
	if error:
		@warning_ignore(&"int_as_enum_without_cast")
		return error
	
	# signal completion
	set_latest_save(save_name)
	save_completed.emit()
	return OK


## Triggers a load procedure that reads all data from the save file on disk to then distribute it to the listeners.
func load_game(save_name: String) -> Error:
	var save_location: String = save_name_to_file_path(save_name)
	if not FileAccess.file_exists(save_location):
		return ERR_FILE_NOT_FOUND
	
	var save_file: FileAccess = FileAccess.open(save_location, FileAccess.READ)
	if not save_file:
		return FileAccess.get_open_error()
	
	var data: Dictionary = save_file.get_var(false) as Dictionary
	if data == null:
		return ERR_FILE_CORRUPT
	
	save_file.close()
	set_latest_save(save_name)
	
	save_data = data
	# Distribute data to load listeners
	load_requested.emit(data)
	
	load_completed.emit()
	return OK

## Returns the name of the latest save, or the default name if there hasn't been one.
func get_latest_save_or_default() -> String:
	return DEFAULT_SAVE_NAME if latest_save.is_empty() else latest_save


#func _unhandled_key_input(_quick_save):
#	if quick_save_enabled and Input.is_action_pressed("quick_save"):
#		save_game(get_latest_save_or_default())


## Constructs a full path to the save.
static func save_name_to_file_path(save_name: String) -> String:
	return SAVE_ROOT.path_join(SAVE_FOLDER).path_join(save_name)
