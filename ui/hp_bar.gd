extends ProgressBar

const HP_MID:float = 0.51
const HP_LOW:float = 0.2

static var hp_style_default:StyleBox = load("uid://yclnlc6ykyr3")
static var hp_style_mid:StyleBox = load("uid://d3rh8oscn2n3y")
static var hp_style_low:StyleBox = load("uid://b70prt3bdufve")


func _ready() -> void:
	await owner.ready
	max_value = get_parent().get_attribute(Unit.Attribute.HP)

func on_update(hp):
	value = get_parent().hp
	add_theme_stylebox_override(&"fill", color_bar(value/max_value))

func color_bar(hp_percent:float) -> StyleBox:
	if hp_percent > HP_MID:
		return hp_style_default
	elif hp_percent < HP_LOW:
		return hp_style_low
	elif hp_percent < HP_MID:
		return hp_style_mid
	else:
		return hp_style_default


