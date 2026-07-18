class_name Constants
const PLAYER_GROUP := &"player"
const ENEMY_GROUP := &"opponent"
const PHYS_PLAYER := 4
const PHYS_ENEMY := 5
static var equip_item_none = load("uid://cmf34gy8bf545")

static func get_physics_layers(faction:StringName) -> Dictionary:
	match faction:
		PLAYER_GROUP:
			return {"self":PHYS_PLAYER,"target":PHYS_ENEMY}
		ENEMY_GROUP:
			return {"self":PHYS_ENEMY,"target":PHYS_PLAYER}
		_:
			return {}
