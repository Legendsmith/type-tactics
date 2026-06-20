extends ProgressBar
func _ready() -> void:
	await owner.ready
	max_value = get_parent().get_attribute(Unit.Attribute.HP)

func _process(delta: float) -> void:
	value = get_parent().hp
