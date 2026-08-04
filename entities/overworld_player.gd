class_name OverworldPlayer
extends OverworldAgent

func _ready() -> void:
	spatial_hash.hash_location_changed.connect(SpatialMap.on_player_hash_location_changed)
	spatial_hash.update()
	if unit_def:
		load_unit_definition(unit_def)
	GameManager.request_hashmap_near.connect(spatial_hash.on_request_hashmap_near)
	add_to_group(Constants.PLAYER_ENTITY)
	add_to_group("overworld_agents")
	tick_offset = 1
	refresh_hp()
	configure_physics(faction)
	bt_player.blackboard.bind_var_to_property(&"target", self , &"target", true)
	bt_player.blackboard.bind_var_to_property(&"action", self , &"action", true)
	bt_player.blackboard.set_var(&"faction", faction) # Set faction
	bt_player.blackboard.set_var(&"max_speed", max_speed)
	bt_player.blackboard.set_var(&"speed", max_speed)


func _physics_process(delta) -> void:
	bt_delta += delta
	if bt_delta > MAX_BT_DELTA:
		spatial_hash.update()
		bt_delta = 0.0

func recieve_damage(_attacker:OverworldAgent,_power:int,_delta:float) -> float:
	return 0

func move(velocity:Vector2,_delta_frames:float = skip_frames+1):
	apply_central_force(velocity)
