@tool
class_name UCDatabase
extends Resource

@export var unlockable_content_store: Dictionary

@export var _category_infos: Array[Dictionary]
@export var _flag_collections_infos: Array[Dictionary]: set = _set_flag_collections
var _flag_collections_infos_lookup: Dictionary[StringName, Dictionary] = {}

var _flag_states: Dictionary[StringName, UCBitset]


func get_category_names() -> Array[StringName]:
	var cats: Array[StringName] = []
	cats.assign(unlockable_content_store.keys())
	return cats


func get_flag_group_names() -> Array[StringName]:
	var groups: Array[StringName] = []
	groups.assign(_flag_collections_infos_lookup.keys())
	return groups


func get_unlockable_category(category_name: StringName) -> Array[UnlockableResource]:
	assert(unlockable_content_store.has(category_name), "Content store does not have unlockable content for given category.")
	return unlockable_content_store.get(category_name) as Array[UnlockableResource]


func set_flag(flag_group: StringName, flag: Variant, state: bool = true) -> void:
	
	assert(flag is String or flag is StringName or flag is int, "flag is supposed to be either the name of the flag or the index of the flag in the group.")
	
	var bitset: UCBitset = _flag_states.get(flag_group) as UCBitset
	if bitset == null:
		assert(false, "Flag group was not found.")
		push_error("Flag group was not found.")
		return
	
	var flag_index: int = _extract_flag_index(flag_group, flag)
	if flag_index == -1:
		assert(false, "Flag '%s' does not exist in flag group '%s' or is invalid" % [flag, flag_group])
		push_error("Flag '%s' does not exist in flag group '%s' or is invalid" % [flag, flag_group])
		return
	
	bitset.set_bit(flag_index, state)


func has_flag_set(flag_group: StringName, flag: Variant) -> bool:
	var bitset: UCBitset = _flag_states.get(flag_group) as UCBitset
	if bitset == null:
		push_warning("attempting to read flag from non-existing flag group")
		return false
	
	var flag_index: int = _extract_flag_index(flag_group, flag)
	return bitset.check_bit(flag_index)


func _extract_flag_index(flag_group: StringName, flag: Variant) -> int:
	const INVALID_FLAG_INDEX: int = -1
	
	var flag_index: int = INVALID_FLAG_INDEX
	if flag is String:
		flag = StringName(flag)
	if flag is StringName:
		var group_info: Dictionary = _flag_collections_infos_lookup.get(flag_group, {}) as Dictionary
		assert(not group_info.is_empty(), "missing group info, database state corrupt.")
		var flag_infos: Dictionary = group_info.get(&"flags", {})
		return flag_infos.get(flag, INVALID_FLAG_INDEX)
	elif flag is int:
		return flag
	else:
		assert(false, "Unexpected type for argument 'flag'")
		push_error("Unexpected type for argument 'flag'")
		return INVALID_FLAG_INDEX


func _set_flag_collections(collection: Array[Dictionary]) -> void:
	_flag_collections_infos = collection
	
	_flag_states = {}
	for flag_collection_info: Dictionary in _flag_collections_infos:
		_flag_collections_infos_lookup.set(flag_collection_info[&"collection_name"], flag_collection_info)
		_flag_states.set(flag_collection_info[&"collection_name"], UCBitset.new(flag_collection_info[&"max_flag"] + 1))
