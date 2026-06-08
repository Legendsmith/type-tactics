@tool
class_name UCValidatedLineEdit
extends LineEdit

enum CasingStrategy {
	UNHANDLED,
	FORCE_LOWER,
	FORCE_UPPER,
}

signal validation_succesful()

@export var casing_strategy: CasingStrategy = CasingStrategy.UNHANDLED
@export var valid_characters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
var old_text: String


func _init() -> void:
	text_changed.connect(_on_text_changed)


func _set(property: StringName, value) -> bool:
	if property == &"text":
		old_text = value
	
	return false


func _on_text_changed(new_text: String) -> void:
	if casing_strategy == CasingStrategy.FORCE_LOWER:
		new_text = new_text.to_lower()
	elif casing_strategy == CasingStrategy.FORCE_UPPER:
		new_text = new_text.to_upper()
	
	for char in new_text:
		if char not in valid_characters:
			text = old_text
			caret_column = old_text.length()
			return
	
	validation_succesful.emit()
	#old_text = new_text
	set(&"text", new_text)
	caret_column = new_text.length()
