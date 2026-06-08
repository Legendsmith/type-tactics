@tool
## A resource that can be managed by the UnlockableContent autoload singleton. This class is not meant
## to be instantiated by itself and instead it should be extended by specialized classes.
## Child classes need to be annotated with @tool in order to be used inside the editor itself.
class_name UnlockableResource
extends Resource


## Determines if the unlockable resource requires a specific flag to be set. If set to false, it is considered unlocked by default.
@export var has_requirement: bool:
	set(state):
		has_requirement = state
		notify_property_list_changed()


## The group name used for looking up which flag set should be used for checking if the resource is unlocked.
var flag_group: StringName:
	set(group):
		if flag_group != group:
			unlock_flag = -1
		flag_group = group
		notify_property_list_changed()

## The flag index of the flag set that will be checked to see if the resource is unlocked.
var unlock_flag: int = -1


## Determines if the resources should be considered unlocked.
func is_unlocked() -> bool:
	if has_requirement:
		assert(not flag_group.is_empty(), "No flag group set.")
		assert(unlock_flag != -1, "Flag is in invalid state.")
		return UnlockableContent.database.has_flag_set(flag_group, unlock_flag)
	
	return true


func _get_display_name() -> String:
	return resource_name


func _get_display_name_property_name() -> StringName:
	return &"resource_name"


## Editor function: Override to get icons in the resource management tabs when creating new resources.
func _get_icon() -> Texture2D:
	return null


## Editor function: The name of the property in charge of supplying the icon. Used for monitoring when to refresh the icon.
func _get_icon_property_name() -> StringName:
	return &""


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	if not has_requirement:
		return properties
	
	var flag_group_names: PackedStringArray = []
	for group_info in UnlockableContent.database._flag_collections_infos:
		flag_group_names.append(group_info[&"collection_name"])
	
	var flag_group_hint: String = ",".join(flag_group_names)
	
	properties.append({
		"name": "flag_group",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": flag_group_hint,
	})
	
	var flag_group_info: Dictionary = UnlockableContent.database._flag_collections_infos_lookup.get(flag_group, {}) as Dictionary
	if not flag_group_info.is_empty():
		var flag_infos: Dictionary = flag_group_info[&"flags"]
		
		var value_sorted_flags = []
		for flag_name: String in flag_infos:
			value_sorted_flags.append([flag_name, flag_infos[flag_name]])
		
		value_sorted_flags.sort_custom(func(a, b) -> bool: return a[1] < b[1])
		
		var kv_pairs: PackedStringArray = []
		for kv_pair in value_sorted_flags:
			kv_pairs.append("%s:%d" % [kv_pair[0], kv_pair[1]])
		
		var unlock_flag_hint: String = ",".join(kv_pairs)
		
		properties.append({
		"name": "unlock_flag",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": unlock_flag_hint,
	})
	
	return properties
