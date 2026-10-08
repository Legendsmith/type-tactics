extends Node2D

@onready var hash_object:SpatialHash = SpatialHash.new(self)
@export var faction:StringName = &""
@export_custom(0,"scene") var entity:String = "uid://8ievdkdx8ig7"
@export var unit_def:UnitDef
@export var spawn_time:float = 1.5

var spawn_timer:float = 0
var recovery_rate:float = 0.1
var spawn_count:int = 3


func _ready() -> void:
	hash_object.update_hash()
	SpatialMap.control_map[hash_object.hash_location] = faction
	SpatialMap.hashmap_faction_check.connect(hash_object.on_hashmap_faction_check)
	SpatialMap.control_updated.connect(on_control_updated)
	$ProgressBar.max_value = spawn_time


func on_control_updated(location:Vector2i,new_faction:StringName) -> void:
	if location == hash_object.hash_location:
		faction = new_faction
		if new_faction != &"":
			process_mode = Node.PROCESS_MODE_INHERIT
		else:
			process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	if faction == SpatialMap.control_map[hash_object.hash_location] and spawn_timer >= spawn_time:
		spawn_timer = 0
		spawn()
	else:
		spawn_timer += delta
	$ProgressBar.value = spawn_timer

func spawn():
	for i in range(spawn_count):
		await get_tree().physics_frame
		var spawn_position:Vector2 = global_position + get_spawn_pos()
		var new_ent:Node2D = load(entity).instantiate()
		new_ent.unit_def = unit_def
		new_ent.faction = faction
		get_tree().current_scene.add_child(new_ent)
		new_ent.global_position = spawn_position
		OverworldAgent.teleport(new_ent,spawn_position)

func get_spawn_pos()-> Vector2:
			return Vector2(
			randf_range(
			$CollisionShape2D.shape.get_rect().position.x,$CollisionShape2D.shape.get_rect().end.x),
			randf_range($CollisionShape2D.shape.get_rect().position.y,$CollisionShape2D.shape.get_rect().end.y)
		)
