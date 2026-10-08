class_name Pointer

class FloatPtr:
	extends RefCounted
	var value: float = 0.0

	func _init(init_value:float=0.0):
		value=init_value

class Vector2Ptr:
	extends RefCounted
	var value: Vector2

	func _init(init_value:Vector2=Vector2.ZERO):
		value=init_value

class BoolPtr:
	extends RefCounted
	var value:bool

	func _init(init_value:bool) -> void:
		value = init_value

class StringNamePtr:
	extends RefCounted
	var value:StringName
	
	func _init(init_value:StringName=&"") -> void:
		value = init_value
