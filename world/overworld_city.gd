extends Node2D

@onready var hash_object:SpatialHash = SpatialHash.new(self)
@export var faction:StringName = &""
@export_custom(0,"scene") var entity:String = "uid://8ievdkdx8ig7"
@export var unit_def:UnitDef
@export var spawn_time:float = 1.5

var spawn_timer:float = 0
var hp:float = 1:
	set(new):
		hp = new
		$ProgressBar.value = hp
		$ProgressBar.visible = not hp == 1
var recovery_rate:float = 0.1
var spawn_count:int = 3


func _ready() -> void:
	hash_object.update_hash()
	SpatialMap.activate_grid.connect(on_activate_grid)
	SpatialMap.hashmap_faction_check.connect(hash_object.on_hashmap_faction_check)
	SpatialMap.control_updated.connect(on_control_updated)
	SpatialMap.request_battle.connect(on_request_battle)
	SpatialMap.control_map[hash_object.hash_location] = faction
	$ProgressBar.visible = false


func on_control_updated(location:Vector2i,new_faction:StringName) -> void:
	if location == hash_object.hash_location:
		if faction == new_faction:
			return
		else:
			faction = new_faction
			hp=0


func _physics_process(delta: float) -> void:
	hp = min(1,hp + delta * recovery_rate)
	if hp == 1 and spawn_timer <= 0:
		spawn_timer = spawn_time
		spawn()
	else:
		spawn_timer -= delta


func on_request_battle(location:Vector2i):
	if location == hash_object.hash_location and hp == 1.0:
		hp = 0.75
		spawn()

func on_activate_grid(coordinates:Vector2i):
	if coordinates == hash_object.hash_location:
		process_mode = Node.PROCESS_MODE_INHERIT

func spawn():
	for i in range(spawn_count):
		await get_tree().physics_frame
	var spawn_position:Vector2 = global_position
	var new_ent:Node2D = load(entity).instantiate()
	new_ent.unit_def = unit_def
	new_ent.faction = faction
	get_tree().current_scene.add_child(new_ent)
	new_ent.global_position = spawn_position
	OverworldAgent.teleport(new_ent,spawn_position)
