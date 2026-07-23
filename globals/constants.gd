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
# NAVIGATION
const NAV_LAYER_ALL := 1
const AVOIDANCE_OFFSET := 0
const FLOW_FIELD_GROUP := &"flow_field_target"

# OVERWORLD
const OVERWORLD_BATTLE_TICK:float = 0.8


static func get_direction_index(input_vector: Vector2) -> int:
	var biased_vector:Vector2 = Vector2(input_vector.x, input_vector.y * SPRITE_H_BIAS) #bias to horizontal by reducing the vertical slightly.
	var angle:float = biased_vector.angle()
	if angle < 0:
		angle += 2 * PI
	return int((angle + PI/SPRITE_DIR) / SPRITE_DIR_COEF) % SPRITE_DIR

static func teleport(body:RigidBody2D,global_position:Vector2):
	PhysicsServer2D.body_set_state(body.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated(global_position))
	body.reset_physics_interpolation()
