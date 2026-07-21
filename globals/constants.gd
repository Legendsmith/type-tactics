class_name Constants

const SPRITE_DIR:int = 4
const SPRITE_DIR_COEF:float = PI/(SPRITE_DIR/2.0)
const SPRITE_H_BIAS:float = 0.84

# Physics and game interactions
const PLAYER_GROUP := &"player"
const ENEMY_GROUP := &"opponent"
const PHYS_TERRAIN := 1
const PHYS_HAZARD := 2
const PHYS_INTERACT := 3
const FACTION_PHYSLAYER_OFFSET := 4
const NAV_LAYER_ALL := 1
const AVOIDANCE_OFFSET := 0

#static var equip_item_none = load("uid://cmf34gy8bf545")


static func get_direction_index(input_vector: Vector2) -> int:
	var biased_vector:Vector2 = Vector2(input_vector.x, input_vector.y * SPRITE_H_BIAS) #bias to horizontal by reducing the vertical slightly.
	var angle:float = biased_vector.angle()
	if angle < 0:
		angle += 2 * PI
	return int((angle + PI/SPRITE_DIR) / SPRITE_DIR_COEF) % SPRITE_DIR
