class_name OverworldAgent
extends RigidBody2D

const DMG_LOW:int = 40
const DMG_HIGH:int = 85
const MAX_BT_DELTA:float = 4.0

@export var team: TeamDef
@export var faction: StringName = Constants.ENEMY_GROUP
@export var goal: StringName = &"move"
@export var speed:float = 100
@export var max_speed:float = 100
@export var target:Node2D
var desired_velocity:Vector2 = Vector2.ZERO

var overworld_atk: int = 0
var overworld_def: int = 0
var overworld_hp: int = 0
var max_overworld_hp: int = 0

var bt_delta: float = 0
var thinking: bool = false
var tick_offset: int = 0
@export_range(0, 60, 1) var skip_frames: int = 8

@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@onready var bt_player: BTPlayer = $BTPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_raycast:ShapeCast2D = $AttackRaycast

func _ready() -> void:
	tick_offset = randi() % Engine.physics_ticks_per_second
	calculate_overworld_power()
	refresh_hp()
	nav_agent.waypoint_reached.connect(think.unbind(1))
	configure_physics(faction)
	_setup_bt_player()

func configure_physics(_faction:StringName):
	var faction_def:Factions.Faction = Factions.faction_list[_faction]
	collision_layer = faction_def.physics_layer
	collision_mask = faction_def.physics_mask
	nav_agent.navigation_layers = faction_def.nav_layer
	nav_agent.avoidance_layers = faction_def.avoid_own
	nav_agent.avoidance_mask = faction_def.avoid_own

func refresh_hp():
	var hp: int = 1
	if not team:
		overworld_hp = 100
		max_overworld_hp = 100
		return
	for unit: UnitDef in team.units:
		hp += unit.attribute_base[Unit.Attribute.HP]
	overworld_hp = hp
	max_overworld_hp = hp


func calculate_overworld_power():
	overworld_atk = 100
	overworld_def = 100

	if overworld_hp <= 0 or not team:
		return
	for unit: UnitDef in team.units:
		overworld_atk += unit.attribute_base[Unit.Attribute.ATTACK] + unit.attribute_base[Unit.Attribute.SPECIAL_ATTACK]
		overworld_def += unit.attribute_base[Unit.Attribute.DEFENSE] + unit.attribute_base[Unit.Attribute.SPECIAL_DEFENSE]
	

func recieve_damage(_attacker:OverworldAgent,atk:int,delta):
	overworld_hp -= randi_range(DMG_LOW,DMG_HIGH) * (atk/overworld_def) * delta
	if overworld_hp <= 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		
		

func _physics_process(delta) -> void:
	bt_delta += delta
	attack_raycast.target_position = desired_velocity.normalized() * 4
	attack_raycast.position = desired_velocity.normalized() * 8
	if bt_delta > MAX_BT_DELTA and not thinking:
		print_debug("Backup think")
		think()

	if attack_raycast.is_colliding():
			var _target:Node2D = attack_raycast.get_collider(0)
			if _target.faction != faction:
				linear_damp = 16
				desired_velocity = Vector2.ZERO
				
				print_debug("Attacking: ", _target)
				_target.recieve_damage(self,overworld_atk,delta)
			else:
				linear_damp = 1
	else:
		linear_damp = 1
	modulate = (Color.WHITE *(float(overworld_hp)/max_overworld_hp)) + Color(0,0,0,1)

func move(velocity:Vector2):
	apply_central_force(velocity)
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
