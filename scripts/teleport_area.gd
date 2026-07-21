class_name TeleportArea
extends Area2D
@export var destination:Node2D
@export var travel_cost:float = 1.15
## Any Node2D is valid, other TeleportAreas can be linked for 2-way connections
var navigation_link:NavigationLink2D
func _ready():
	#set_collision_mask_value(4,true)
	#set_collision_mask_value(5,true)
	body_entered.connect(teleport)
	var link:NavigationLink2D = NavigationLink2D.new()
	add_child(link)
	link.set_global_start_position(self.global_position)
	link.set_global_end_position(destination.global_position)
	link.travel_cost = travel_cost
	if destination is TeleportArea:
		if not is_instance_valid(destination.destination):
			destination.destination = self
		link.bidirectional = true
	link=navigation_link



func teleport(body:RigidBody2D):
	PhysicsServer2D.body_set_state(body.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated(destination.global_position))
	body.reset_physics_interpolation()
