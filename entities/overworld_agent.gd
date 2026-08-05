class_name OverworldAgent
extends RigidBody2D
const MAX_BT_DELTA:float = 4.0
signal inflicted_damage(who:Node2D,amount:int,damage_target:Node2D)

const SPRITE_DIR:int = 4
const SPRITE_DIR_COEF:float = PI/(SPRITE_DIR/2.0)
const SPRITE_H_BIAS:float = 0.84


@export var faction: StringName = Constants.ENEMY_GROUP
@export var action: StringName = &"move":
	set=set_action
@export var speed:float = 64
@export var max_speed:float = 64
@export var target:Node2D
var desired_velocity:Vector2 = Vector2.ZERO

@export var overworld_pwr: int = 60
@export var overworld_atk: int = 95
@export var overworld_def: int = 100
@export var overworld_hp: float = 100
@export var max_overworld_hp: int = 100
@export var unit_def:UnitDef
var damage_inflicted:float = 0
#var attack_charge:float = 0

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
	spatial_hash.hash_location_changed.connect(on_hash_location_changed)
	if unit_def:
		load_unit_definition(unit_def)
	GameManager.request_hashmap_near.connect(spatial_hash.on_request_hashmap_near)
	add_to_group("overworld_agents")
	tick_offset = randi() % Engine.physics_ticks_per_second
	refresh_hp()
	nav_agent.waypoint_reached.connect(think.unbind(1))
	configure_physics(faction)
	if NavigationServer2D.map_is_active(get_world_2d().get_navigation_map()):
		_setup_bt_player()
	else:
		#print_debug("Awaiting NavigationServer")
		await NavigationServer2D.map_changed
		_setup_bt_player()


func load_unit_definition(unit_definition:UnitDef):
	unit_def = unit_definition
	overworld_pwr = unit_def.get_overworld_power()
	overworld_atk = unit_def.attribute_base[Unit.Attribute.ATTACK]
	overworld_def = unit_def.attribute_base[Unit.Attribute.DEFENSE]
	overworld_hp = unit_def.attribute_base[Unit.Attribute.HP]
	max_speed = unit_def.get_modified_overworld_speed()
	$Sprite2D.texture = unit_def.overworld_sprite
	name = "OverworldAgent%" + unit_def.unit_name.capitalize()

func set_action(new_action:StringName):
	action = new_action
	contact_monitor = new_action == &"attack"

func configure_physics(_faction:StringName):
	var faction_def:Factions.Faction = Factions.faction_list[_faction]
	collision_layer = faction_def.physics_layer
	collision_mask = faction_def.physics_mask | collision_layer
	nav_agent.navigation_layers = faction_def.nav_layer
	nav_agent.avoidance_layers = faction_def.avoid_own
	nav_agent.avoidance_mask = Factions.master_avoid


func refresh_hp():
	overworld_hp = max_overworld_hp


func calculate_overworld_attributes():
	pass


func recieve_damage(attacker:OverworldAgent,power:int,delta:float) -> float:
	var ratio:float = float(attacker.overworld_atk)/float(overworld_def)
	var dmg:float = power * ratio * delta
	overworld_hp -= dmg
	#modulate = (Color.WHITE *(float(overworld_hp)/max_overworld_hp)) + Color(0,0,0,1)
	animation_player.play(&"hurt",-1,1)
	#print_debug("%s recieved %f damage from %s. \n| Ratio | Delta |\n|  %f  |  %f  |" % [name, dmg,attacker.name, ratio, delta])
	if overworld_hp <= 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		$CollisionShape2D.disabled = true
		modulate = Color.DARK_RED
		$Sprite2D.rotation = PI/2
	return dmg
		

func _physics_process(delta) -> void:
	bt_delta += delta
	if contact_monitor:
		var contact_count = get_contact_count()
		for i:int in range(contact_count):
			var contact_target:Node2D = get_colliding_bodies()[i]
			if contact_target is TileMapLayer or contact_target.faction == faction:
				continue
			var roll:float = randf_range(Constants.OVERWORLD_DAMAGE_VARIANCE,1)
			var dmg:float = contact_target.recieve_damage(self,overworld_pwr*roll,delta)
			#attack_charge -= delta
			inflicted_damage.emit(self,dmg,contact_target)
			damage_inflicted += dmg
		#attack_charge = clampf(attack_charge+(delta/5),0,Constants.OVERWORLD_MAX_ATTACK_CHARGE)
		
	if (Engine.get_physics_frames() + tick_offset) % (skip_frames + 1) == 0:
		spatial_hash.update()
		if use_flow_field:
			follow_flow_field()
	if bt_delta > MAX_BT_DELTA and not thinking:
		#print_debug("Backup think")
		spatial_hash.update()
		think()

func move(velocity:Vector2,delta_frames:float = skip_frames+1):
	apply_central_force(velocity*(delta_frames+linear_damp))
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
		print_debug(name, "experienced behaviour tree failure.")

func _setup_bt_player():
	bt_player.blackboard.bind_var_to_property(&"target", self , &"target", true)
	bt_player.blackboard.bind_var_to_property(&"action", self , &"action", true)
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

func on_hash_location_changed(new_location:Vector2i):
	if use_flow_field:
		SpatialMap.agent_request_flow_field.emit(self,new_location)


func follow_flow_field() -> void:
	var distance:float = global_position.distance_to(target.global_position)
	var dir=flow_field.get_direction(global_position)
	desired_velocity = dir * min(distance,speed)
	#agent.linear_damp = MAX_LINEAR_DAMP * flow_field.get_move_multiplier(flow_field.get_grid_coords(agent.global_position))
	move(desired_velocity)
	animation_player.play("move_"+str(OverworldAgent.get_direction_index(dir)),-1,max(0.25,linear_velocity.length_squared()/(max_speed*max_speed)))

## Spatial Hash related
func _exit_tree() -> void:
	spatial_hash.free()

func _enter_tree() -> void:
	spatial_hash = SpatialHash.new(self)

func get_goal() ->Node2D:
	## todo make this more elegant
	var goal:Node2D
	if faction == &"player":
		goal = get_tree().current_scene.player_faction_goal
	else:
		goal = get_tree().current_scene.enemy_faction_goal
	return goal

static func get_direction_index(input_vector: Vector2) -> int:
	var biased_vector:Vector2 = Vector2(input_vector.x, input_vector.y * SPRITE_H_BIAS) #bias to horizontal by reducing the vertical slightly.
	var angle:float = biased_vector.angle()
	if angle < 0:
		angle += 2 * PI
	return int((angle + PI/SPRITE_DIR) / SPRITE_DIR_COEF) % SPRITE_DIR

static func teleport(body:RigidBody2D,new_global_position:Vector2):
	PhysicsServer2D.body_set_state(body.get_rid(),PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated(new_global_position))
	body.reset_physics_interpolation()
	body.on_hash_location_changed(Vector2i(new_global_position/Constants.SPATIAL_HASH_SIZE))
	body.think()
