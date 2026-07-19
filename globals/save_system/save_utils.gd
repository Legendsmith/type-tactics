## A Utility class used to have a general purpose serializer and deserializer for resource objects when saving and loading to disk.
## For finer control, implementing your own (de-)serialization pipeline to convert to and from dictionaries is another option.
class_name SaveUtils

static var _class_list_cache: Dictionary


static func _static_init() -> void:
	reset_class_list_cache()


static func reset_class_list_cache() -> void:
	_class_list_cache = {}
	for class_info: Dictionary in ProjectSettings.get_global_class_list():
		if class_info["language"] == &"GDScript":
			_class_list_cache[class_info["class"]] = {
				"path": class_info["path"]
			}


## Finds the script instance of the class in the cache and adds it if it was not found.
static func find_class(name: String) -> GDScript:
	var class_info: Dictionary = _class_list_cache.get(name, {}) as Dictionary
	if class_info.is_empty():
		return null
	
	var instance: GDScript = class_info.get("instance") as GDScript
	if instance:
		return instance
	
	instance = load(class_info["path"])
	class_info["instance"] = instance
	return instance


## Turns a resource object into a dictionary representation storing all properties marked with PROPERTY_USAGE_STORAGE.
## This function treats resources as is and will not handle multiple references to the same object correctly.[br]
## [br]
## The resulting dictionary has the following entries:[br]
## [code]resource_type[/code] - The string with the class' name. if the class is an inner class, "__inner_class" will be used.[br]
## [code]data[/code] - A dictionary containing the properties marked as [constant PROPERTY_USAGE_STORAGE].[br]
## [br]
## Even though inner classes can be serialized by this function, they cannot be handled by [method deserialize_dictionary] 
## and you need to use your own deserialization logic.
static func serialize_to_dictionary(object: Resource) -> Dictionary:
	var result: Dictionary = {}
	var result_data: Dictionary = {}
	
	var object_script = object.get_script() as GDScript
	if object_script:
		var object_class_name: String = object_script.get_global_name()
		if object_class_name.is_empty():
			# NOTE: Inner class currently doesn't have a good way of figuring out what the actual class is.
			result["resource_type"] = "__inner_class"
		else:
			result["resource_type"] = object_class_name
	else:
		result["resource_type"] = object.get_class()
	
	result["data"] = result_data
	
	print(object.get_property_list())
	for property_info in object.get_property_list():
		# Skip properties that aren't meant to be saved to disk
		if not property_info["usage"] & PROPERTY_USAGE_STORAGE:
			continue
		
		var property_name: String = property_info["name"]
		var property_value: Variant = object.get(property_name)
		
		if property_name == "script" or property_name == "resource_local_to_scene":
			continue
		
		if property_info["type"] == TYPE_OBJECT:
			# Recursively serialize resources into dictionaries
			var property_object = property_value as Resource
			if property_object:
				result_data[property_name] = serialize_to_dictionary(property_object)
		else:
			result_data[property_name] = property_value
	
	return result


## Automatically deserializes a dictionary representation of a resource back into an instance of a resource.
## If the resource has a custom constructor, all arguments must be optional.
static func deserialize_dictionary(dictionary: Dictionary) -> Resource:
	var resource_class_name: String = dictionary.get("resource_type", "") as String
	if resource_class_name.is_empty():
		return null
	
	if resource_class_name == "__inner_class":
		assert(false, "deserialize_dictionary cannot handle inner classes, please use a custom deserialize method instead.")
		return null
	
	var resource_object: Resource
	if ClassDB.class_exists(resource_class_name):
		resource_object = ClassDB.instantiate(resource_class_name) as Resource
	else:
		resource_object = SaveUtils.find_class(resource_class_name).new() as Resource
	
	assert(resource_object, "Failed to create instance of '%s'" % resource_class_name) 
	
	var resource_data: Dictionary = dictionary["data"] as Dictionary
	for property in resource_data:
		var property_value: Variant = resource_data[property] as Variant
		
		if property_value is Dictionary:
			var property_value_dict: Dictionary = property_value as Dictionary
			if property_value_dict.size() == 2 and property_value_dict.has("resource_type") and property_value_dict.has("data"):
				property_value = deserialize_dictionary(property_value)
		
		resource_object.set(property, property_value)
	
	return resource_object
