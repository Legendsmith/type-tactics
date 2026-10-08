class_name SpatialHash
extends Object
signal hash_location_changed(new_location: Vector2i)

const NEAR_MAP: Array[Vector2i] = [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1),
	Vector2i(-1, 1), Vector2i(1, 1), Vector2i(1, 1),
]

var agent: Node2D
var hash_location: Vector2i
var hash_near: Array[Vector2i]
var astar_point_id: int


func _init(_agent: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	agent = _agent
	SpatialMap.request_hashmap_near.connect(on_request_hashmap_near)
	SpatialMap.request_hashmap_near_filter.connect(on_request_hashmap_near_filter)
	if agent is OverworldAgent:
		hash_location_changed.connect(on_hash_location_changed)
		SpatialMap.hashmap_faction_check.connect(on_hashmap_faction_check)


func update() -> void:
	update_hash.call_deferred()


## Updates the spatial hash location of the agent.
func update_hash(forced: bool = false) -> void:
	var position: Vector2 = agent.global_position
	var new_hash: Vector2i = Vector2i(position / Constants.SPATIAL_HASH_SIZE)
	if new_hash == hash_location and not forced:
		return
	SpatialMap.hashmap_point_id.emit(self)
	var new_near: Array = NEAR_MAP.map(func(vec: Vector2i) -> Vector2i: return vec + new_hash)
	hash_location = new_hash
	hash_location_changed.emit(hash_location)
	hash_near.assign(new_near)

func on_hash_location_changed(location: Vector2i) -> void:
	if SpatialMap.control_map.has(location):
		if SpatialMap.control_map[location] == agent.faction or SpatialMap.control_map[location] == Constants.UPDATE or SpatialMap.control_map[location] == Constants.CONTEST:
			return
		else:
			SpatialMap.control_map[location] = Constants.UPDATE
			if SpatialMap.control_map_update_ready and not SpatialMap.dirty_control_map:
				SpatialMap.dirty_control_map = true
				SpatialMap.check_control.call_deferred()
	else:
		SpatialMap.update_control(location,agent.faction)


func on_hashmap_faction_check(control_faction:Pointer.StringNamePtr,check: Pointer.BoolPtr,  coordinates:Vector2i) -> void:
	if coordinates == hash_location:
		if control_faction.value == &"":
			control_faction.value = agent.faction
			return
		print_debug("Check: Agent faction %s | %s" % [agent.faction,control_faction.value])
		if check.value:
			check.value = control_faction.value == agent.faction


func on_request_hashmap_near(list: Array, coordinates: Vector2i, faction: StringName = &"") -> void:
	if coordinates in hash_near:
		if faction == agent.faction or faction == &"":
			list.append(agent)


func on_request_hashmap_near_filter(list: Array, coordinates: Vector2i, faction: StringName, method: Callable) -> void:
## Calls a method on its agent when requested.
	if agent.faction == faction and coordinates in hash_near and method.call(agent):
		list.append(agent)
