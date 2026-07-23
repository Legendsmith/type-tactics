class_name OverworldAgent
extends RigidBody2D

const DMG_LOW:int = 40
const DMG_HIGH:int = 85
const MAX_BT_DELTA:float = 4.0

@export var faction: StringName = Constants.ENEMY_GROUP
@export var goal: StringName = &"move"
@export var speed:float = 64
@export var max_speed:float = 64
@export var target:Node2D
var desired_velocity:Vector2 = Vector2.ZERO

var overworld_atk: int = 95
var overworld_def: int = 100
var overworld_hp: int = 100
var max_overworld_hp: int = 100

var bt_delta: float = 0
var thinking: bool = false
var tick_offset: int = 0

var spatial_hash:Object

@export_range(0, 60, 1) var skip_frames: int = 8

@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var bt_player: BTPlayer = $BTPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var use_flow_field=false
var flow_field:FlowField

func _ready() -> void:
	spatial_hash.update()
	GameManager.request_hashmap_near.connect(spatial_hash.on_request_hashmap_near)
	add_to_group("overworld_agents")
	if not target:
		target = get_tree().get_first_node_in_group(Constants.FLOW_FIELD_GROUP)
	tick_offset = randi() % Engine.physics_ticks_per_second
	refresh_hp()
	nav_agent.waypoint_reached.connect(think.unbind(1))
	configure_physics(faction)
	if NavigationServer2D.map_is_active(get_world_2d().get_navigation_map()):
		_setup_bt_player()
	else:
		print_debug("Awaiting NavigationServer")
		await NavigationServer2D.map_changed
		_setup_bt_player()

func configure_physics(_faction:StringName):
	var faction_def:Factions.Faction = Factions.faction_list[_faction]
	collision_layer = faction_def.physics_layer
	collision_mask = faction_def.physics_mask
	nav_agent.navigation_layers = faction_def.nav_layer
	nav_agent.avoidance_layers = faction_def.avoid_own
	nav_agent.avoidance_mask = faction_def.avoid_own


func refresh_hp():
	overworld_hp = max_overworld_hp

func calculate_overworld_power():
	pass


func recieve_damage(_attacker:OverworldAgent,atk:int,delta):
	overworld_hp -= randi_range(DMG_LOW,DMG_HIGH) * (atk/overworld_def) * delta
	if overworld_hp <= 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		
		

func _physics_process(delta) -> void:
	bt_delta += delta
	if (Engine.get_physics_frames() + tick_offset) % (skip_frames + 1) == 0:
		if use_flow_field:
			follow_flow_field()
	if bt_delta > MAX_BT_DELTA and not thinking:
		#print_debug("Backup think")
		think()
		spatial_hash.update()
	modulate = (Color.WHITE *(float(overworld_hp)/max_overworld_hp)) + Color(0,0,0,1)

func move(velocity:Vector2):
	apply_central_force(velocity)
	animation_player.play("move_"+str(Constants.get_direction_index(velocity)),-1,linear_velocity.length()/max_speed)
	#if (Engine.get_physics_frames() + tick_offset) % (skip_frames + 1) == 0: # Only run this every skip frames.
	#	linear_velocity = velocity

#region BehaviorTree
## Call the BT player for update.
func think():
	if not thinking: # if it's been more than a frame since we last thought
		#print_debug(name, " thinking")
		thinking = true
		for i: int in Engine.physics_ticks_per_second:
			if (Engine.get_physics_frames() + tick_offset) % (skip_frames + 1) == 0: # Only run this every skip frames.
				bt_player.update(bt_delta)
				bt_delta = 0 # reset since we just thought.
				break
			else:
				await get_tree().physics_frame

#func _draw() -> void:
#	draw_line(Vector2.ZERO,desired_velocity,nav_agent.debug_path_custom_color)

func bt_status(status:BT.Status):
	thinking = false # not thinking anymore.
	if status == BT.FAILURE:
		think()

func _setup_bt_player():
	bt_player.blackboard.bind_var_to_property(&"target", self , &"target", true)
	bt_player.blackboard.set_var(&"faction", faction) # Set faction
	bt_player.blackboard.set_var(&"max_speed", max_speed)
	bt_player.blackboard.set_var(&"speed", max_speed)
	bt_player.updated.connect(bt_status)
	animation_player.animation_finished.connect(think.unbind(1)) # Call BT player when we finish an animation
	#nav_agent.navigation_finished.connect(think)
	await get_tree().current_scene.ready
	bt_player.set_active(true)
	bt_player.update(1.0 / Engine.physics_ticks_per_second) # Update since it's manual.
	#damage_recieved.connect(think.unbind(1))
#endregion


func activate_flow_field(target_flow_field:FlowField):
	use_flow_field = true
	flow_field = target_flow_field


func follow_flow_field() -> void:
	var distance:float = global_position.distance_to(target.global_position)
	var dir=flow_field.get_direction(global_position)
	desired_velocity = dir * min(distance,max_speed)
	#agent.linear_damp = MAX_LINEAR_DAMP * flow_field.get_move_multiplier(flow_field.get_grid_coords(agent.global_position))
	move(desired_velocity*(skip_frames+1))

## Spatial Hash related
func _exit_tree() -> void:
	spatial_hash.free()

func _enter_tree() -> void:
	spatial_hash = SpatialHash.new(self)
