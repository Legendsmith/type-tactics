class_name OverworldPlayer
extends OverworldAgent

func _ready() -> void:
	spatial_hash.update()
	GameManager.request_hashmap_near.connect(spatial_hash.on_request_hashmap_near)
	add_to_group(Constants.PLAYER_ENTITY)
	add_to_group("overworld_agents")
	tick_offset = 1
	refresh_hp()
	configure_physics(faction)
	_setup_bt_player()


func _physics_process(delta) -> void:
	bt_delta += delta
	if bt_delta > MAX_BT_DELTA:
		spatial_hash.update()
		bt_delta = 0.0

func recieve_damage(_attacker:OverworldAgent,_power:int,_delta:float) -> float:
	return 0

func move(velocity:Vector2,_delta_frames:float = skip_frames+1):
	apply_central_force(velocity)
