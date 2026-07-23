extends TeleportArea
@export var destinations:Array[Node2D]

func teleport(body:RigidBody2D):
	Constants.teleport(body,destinations.pick_random().global_position)
