extends TeleportArea
@export var destinations:Array[Node2D]

func teleport(body:RigidBody2D):
	PhysicsServer2D.body_set_state(body.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated(destinations.pick_random().global_position))
	body.reset_physics_interpolation()

