class_name SpatialHash
extends Object

const SPATIAL_HASH_SIZE := 512
const NEAR_MAP: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1),
	Vector2i(-1, 1), Vector2i(1, 1), Vector2i(1, 1),
]

var agent: Node2D
var hash_location: Vector2i
var hash_near: Array[Vector2i]

func _init(_agent:Node2D) -> void:
	agent = _agent

func update() -> void:
	update_hash.call_deferred()

## Updates the spatial hash location of the agent.
func update_hash(forced: bool = false) -> void:
	var position: Vector2 = agent.global_position
	var new_hash: Vector2i = Vector2i(position / SPATIAL_HASH_SIZE)
	if new_hash == hash_location and not forced:
		return
	var new_near: Array = NEAR_MAP.map(func(vec:Vector2i)->Vector2i: return vec + new_hash)
	hash_location = new_hash
	hash_near.assign(new_near)


func on_request_hashmap_near(list: Array, coordinates: Vector2i, faction:StringName=&"") -> void:
	if coordinates in hash_near:
		if faction == agent.faction or faction == &"":
			list.append(agent)



func on_request_hashmap_near_filter(list: Array, coordinates: Vector2i, faction:StringName, method: Callable) -> void:
## Calls a method on its agent when requested.
	if agent.faction == faction and coordinates in hash_near and method.call(agent):
		list.append(agent)
