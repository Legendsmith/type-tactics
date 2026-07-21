extends Label
@export var target_node:Node
@export var property:StringName
@export var update_frames:int

func _physics_process(_delta):
	if Engine.get_physics_frames() % ( update_frames+ 1 ) == 0:
		text=property +": " + str(target_node[property])

	
