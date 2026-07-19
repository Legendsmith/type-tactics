class_name TeleportArea
extends Area2D
@export var destination:Node2D
@export var travel_cost:float = 1.15
## Any Node2D is valid, other TeleportAreas can be linked for 2-way connections
var exceptions:Array[Node2D] =[]
func _ready():
	collision_layer=0
	collision_mask=0
	monitorable = false
	#set_collision_mask_value(4,true)
	#set_collision_mask_value(5,true)
	body_entered.connect(teleport)
	body_exited.connect(reset_exception)
	var link:NavigationLink2D = NavigationLink2D.new()
	add_child(link)
	link.set_global_start_position(self.global_position)
	link.set_global_end_position(destination.global_position)
	link.travel_cost = travel_cost
	if destination is TeleportArea:
		if not is_instance_valid(destination.destination):
			destination.destination = self
		link.bidirectional = true


func reset_exception(body:Node2D):
	if body in exceptions:
		exceptions.erase.call_deferred(body) #defer the call

func teleport(body:Node2D):
	if not body in exceptions:
		if destination is TeleportArea:
			#destination.exceptions.append(body)
			pass
		body.global_position = destination.global_position
		body.reset_physics_interpolation()
