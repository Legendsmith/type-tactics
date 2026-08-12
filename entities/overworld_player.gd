class_name OverworldPlayer
extends OverworldAgent

const INTERACT_RANGE:float = 32

func _ready() -> void:
	spatial_hash.hash_location_changed.connect(SpatialMap.on_player_hash_location_changed)
	spatial_hash.update()
	if unit_def:
		load_unit_definition(unit_def)
	GameManager.request_hashmap_near.connect(spatial_hash.on_request_hashmap_near)
	add_to_group(Constants.PLAYER_ENTITY)
	add_to_group("overworld_agents")
	animation_player.animation_started.connect(set_facing)
	tick_offset = 1
	refresh_hp()
	configure_physics(faction)
	collision_layer = collision_layer | (1 << Constants.PLAYER_PHYSICS_LAYER)
	bt_player.blackboard.bind_var_to_property(&"target", self , &"target", true)
	bt_player.blackboard.bind_var_to_property(&"action", self , &"action", true)
	bt_player.blackboard.set_var(&"faction", faction) # Set faction
	bt_player.blackboard.set_var(&"max_speed", max_speed)
	bt_player.blackboard.set_var(&"speed", max_speed)
	contact_monitor = true


func _physics_process(delta) -> void:
	bt_delta += delta
	if bt_delta > MAX_BT_DELTA:
		spatial_hash.update()
		bt_delta = 0.0
	if contact_monitor:
		var count:int = get_contact_count()
		for i:int in range(count):
			var contact_target:Node2D = get_colliding_bodies()[0]
			if contact_target is TileMapLayer or contact_target.faction == faction:
				return
			var roll:float = randf_range(Constants.OVERWORLD_DAMAGE_VARIANCE,1)
			var dmg:float = contact_target.recieve_damage(self,overworld_pwr*roll,delta)
			#attack_charge -= delta
			inflicted_damage.emit(self,dmg,contact_target)
			damage_inflicted += dmg
			#attack_charge = clampf(attack_charge+(delta/5),0,Constants.OVERWORLD_MAX_ATTACK_CHARGE)

func recieve_damage(_attacker:OverworldAgent,_power:int,_delta:float) -> float:
	return 0

func move(velocity:Vector2,_delta_frames:float = skip_frames+1):
	apply_central_force(velocity)

func think():
	pass

func interact():
	var interact_direction:Vector2 = facing * INTERACT_RANGE
	print_debug(interact_direction)
	var q:PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position,global_position+interact_direction,(1<<Constants.PHYS_INTERACT),[get_rid()])
	q.hit_from_inside = true
	var result:Dictionary = get_world_2d().direct_space_state.intersect_ray(q)
	print(result)
	if result and result["collider"] is OverworldAgent:
		result.collider.on_interact()
