extends Node
@export var spawn_points:Array[Node2D]
@export var skip_frames:int = 2
@export var entity:PackedScene
var spawn_enabled:bool

func _ready() -> void:
	await get_tree().current_scene.ready
	_setup()

func _setup() -> void:
	var check_button:CheckButton = GameManager.game_interface.ui_agent_spawn_button
	spawn_enabled = check_button.button_pressed
	check_button.toggled.connect(
		func(value:bool):
			spawn_enabled = value
	)
	
func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % (skip_frames + 1) == 0 and spawn_enabled:
		spawn()

func spawn():
	var spawn_position:Vector2 = spawn_points.pick_random().global_position
	var new_ent:Node2D = entity.instantiate()
	get_tree().current_scene.add_child(new_ent)
	new_ent.global_position = spawn_position
	Constants.teleport(new_ent,spawn_position)
