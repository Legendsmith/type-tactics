extends Node2D
signal battle_over(winner:StringName)
var spatial_hash:Object

const ATK_RANGE:float = 24 * 24

var physics_query:Dictionary[StringName,PhysicsShapeQueryParameters2D]
var shape:Shape2D = load("uid://c43uu5i1l3yab")
var damage_timer:Timer
@onready var side_a:StringName = Factions.faction_list.keys()[0]
@onready var side_b:StringName = Factions.faction_list.keys()[1]

func _ready() -> void:
	damage_timer = Timer.new()
	damage_timer.wait_time = Constants.OVERWORLD_BATTLE_TICK
	add_child(damage_timer)
	damage_timer.timeout.connect(_tick)
	damage_timer.start()
	build_query(side_a)
	build_query(side_b)

func _exit_tree() -> void:
	spatial_hash.free()

func _enter_tree() -> void:
	spatial_hash = SpatialHash.new(self)


func build_query(key:StringName):
	var faction:Factions.Faction = Factions.faction_list[key]
	var q:PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	q.shape = shape
	q.transform = Transform2D.IDENTITY.translated(self.global_position)
	q.collision_mask = faction.physics_layer
	physics_query[key] = q

func _tick():
	var a_attackers:Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(
		physics_query[side_a]
	)
	var b_attackers:Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(
		physics_query[side_b]
	)
	if a_attackers.size() == 0:
		battle_over.emit(b_attackers)
		damage_timer.stop()
		get_tree().set_group("overworld_agents","action",&"move")
		print_debug("Battle over")
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	if b_attackers.size() == 0:
		battle_over.emit(a_attackers)
		damage_timer.stop()
		get_tree().set_group("overworld_agents","action",&"move")
		print_debug("Battle over")
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	battle(a_attackers,b_attackers)
	battle(b_attackers,a_attackers)
	

func battle(attacker:Array[Dictionary],defender:Array[Dictionary]):
	for dict:Dictionary in attacker:
		var agent:OverworldAgent = dict[&"collider"]
		agent.use_flow_field=false
		var target:OverworldAgent = defender.pick_random()[&"collider"]
		agent.target = target
		agent.action = &"attack"
		if agent.global_position.distance_squared_to(target.global_position) > ATK_RANGE:
			agent.desired_velocity = agent.global_position.direction_to(target.global_position)*agent.max_speed
			agent.move(agent.desired_velocity)
			continue
		target.recieve_damage(agent,agent.overworld_atk,1)
