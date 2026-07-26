extends Node2D
signal battle_over(winner:StringName)
var spatial_hash:Object

const ATK_RANGE:float = 24 * 24

var physics_query:Dictionary[StringName,PhysicsShapeQueryParameters2D]
var shape:Shape2D = load("uid://c43uu5i1l3yab")
var damage_timer:Timer
@onready var side_a:StringName = Factions.faction_list.keys()[0]
@onready var side_b:StringName = Factions.faction_list.keys()[1]
var winner:StringName = &""
var participants:Array[Node2D]

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
	q.exclude = [get_tree().get_first_node_in_group(Constants.PLAYER_ENTITY).get_rid()] # need this so player ent won't get mind controlled
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
		winner = side_b
		end_battle()
		return
	if b_attackers.size() == 0:
		battle_over.emit(a_attackers)
		winner = side_a
		end_battle()
		return
	battle(a_attackers,b_attackers)
	battle(b_attackers,a_attackers)
	

func battle(attacker:Array[Dictionary],defender:Array[Dictionary]):
	for dict:Dictionary in attacker:
		var agent:OverworldAgent = dict[&"collider"]
		if not agent in participants:
			participants.append(agent)
		agent.use_flow_field=false
		var target:PhysicsBody2D = defender.pick_random()[&"collider"]
		agent.target = target
		agent.action = &"attack"
		var direction:Vector2 = agent.global_position.direction_to(target.global_position)
		if agent.global_position.distance_squared_to(target.global_position) > ATK_RANGE:
			#agent.move(agent.desired_velocity,Engine.physics_ticks_per_second/Constants.OVERWORLD_BATTLE_TICK)
			agent.linear_velocity = direction * agent.speed
			agent.animation_player.play("move_"+str(Constants.get_direction_index(direction)),-1,1)
			continue
		agent.animation_player.play("move_"+str(Constants.get_direction_index(direction)),-1,3)
		agent.linear_velocity = agent.global_position - target.global_position
			
		#target.recieve_damage(agent,agent.overworld_pwr,1)

func end_battle():
		damage_timer.stop()
		
		print_debug("Battle over! Winner: %s" % Factions.faction_list[winner].name)
		var titles:PackedStringArray = []
		titles.resize(participants.size())
		var values:PackedStringArray = []
		values.resize(participants.size())
		for i:int in range(participants.size()):
			var agent:Node2D = participants[i]
			agent.action = &"move"
			values[i] = "  %1.2f  " % agent.damage_inflicted
			titles[i] = str(agent.name).replace("OverworldAgent","")
		var columns:PackedStringArray = []
		columns.resize(participants.size())
		columns.fill(" --- ")
		print("| "+ " | ".join(titles) + " |")
		print("| "+ " | ".join(columns) + " |")
		print("| "+ " | ".join(values) + " |")
		process_mode = Node.PROCESS_MODE_DISABLED
