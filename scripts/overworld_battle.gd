extends Node2D
signal battle_over(winner:StringName)
var spatial_hash:SpatialHash

const ATK_RANGE:float = 24 * 24

var physics_query:Dictionary[StringName,PhysicsShapeQueryParameters2D]
var shape:Shape2D = load("uid://diaqls5q1pn3")
var damage_timer:Timer
@onready var side_a:StringName = Factions.faction_list.keys()[0]
@onready var side_b:StringName = Factions.faction_list.keys()[1]
var winner:StringName = &""
var participants:Array[Node2D]
var count:int = 0

func _ready() -> void:
	damage_timer = Timer.new()
	spatial_hash.update_hash()
	SpatialMap.request_battle.connect(reactivate)
	damage_timer.wait_time = Constants.OVERWORLD_BATTLE_TICK
	add_child(damage_timer)
	damage_timer.timeout.connect(_tick)
	damage_timer.start()
	await get_tree().physics_frame
	build_query(side_a)
	build_query(side_b)
	print_debug("Starting battle at ", global_position)
	_tick()


func _exit_tree() -> void:
	spatial_hash.free()

func _enter_tree() -> void:
	spatial_hash = SpatialHash.new(self)

func reactivate(coordinates:Vector2i):
	if coordinates == spatial_hash.hash_location:
		participants.clear()
		process_mode = Node.PROCESS_MODE_INHERIT
		count +=1
		visible=true
		print_debug("Battle number %s at previously contested %s" % [count+1, global_position])


func build_query(key:StringName):
	var faction:Factions.Faction = Factions.faction_list[key]
	var q:PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	q.shape = shape
	q.transform = Transform2D.IDENTITY.translated(self.global_position + (Vector2.ONE * Constants.SPATIAL_HASH_SIZE * 0.5))
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
		agent.action = &"attack"
		if not agent.target in participants or agent.target.overworld_hp <= 0:
			var target:PhysicsBody2D = defender.pick_random()[&"collider"]
			agent.target = target
		if agent.global_position.distance_squared_to(agent.target.global_position) < ATK_RANGE:
			var direction = agent.global_position.direction_to(agent.target.global_position)
			agent.linear_velocity = direction * agent.speed


func end_battle():
		damage_timer.stop()
		SpatialMap.control_map[spatial_hash.hash_location] = winner
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
		visible = false
		#queue_free()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,shape.size),Color.YELLOW * Color(1,1,1,0.2))
