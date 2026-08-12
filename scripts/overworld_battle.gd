extends Area2D
signal battle_over(winner:StringName)
var spatial_hash:SpatialHash

const ATK_RANGE:float = 24 * 24

var damage_timer:Timer
@onready var side_a:StringName = Factions.faction_list.keys()[0]
@onready var side_b:StringName = Factions.faction_list.keys()[1]
var winner:StringName = &""
var participants:Array[Node2D]
var count:int = 0
var collision_shape:CollisionShape2D

@onready var active_fighters:Dictionary[StringName,Array] = {side_a:[],side_b:[]}

func _ready() -> void:
	damage_timer = Timer.new()
	monitorable = false
	monitoring =true
	spatial_hash.update_hash()
	# Damage timer for assigning targets to battle participants
	SpatialMap.request_battle.connect(reactivate)
	damage_timer.wait_time = Constants.OVERWORLD_BATTLE_TICK
	add_child(damage_timer)
	damage_timer.timeout.connect(_tick)
	damage_timer.start()
	#colllision
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = load(Constants.OVERWORLD_PHYSICS_QUERY_SHAPE_RESOURCE)
	add_child(collision_shape)
	collision_shape.position = Vector2.ONE * Constants.SPATIAL_HASH_SIZE * 0.5 # offset it since a shape's position is its centre
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	visible = false
	collision_mask = Factions.faction_list[side_a].physics_layer | Factions.faction_list[side_b].physics_layer
	await get_tree().physics_frame
	print_debug("Starting battle at ", global_position)
	


func _exit_tree() -> void:
	spatial_hash.free()

func _enter_tree() -> void:
	spatial_hash = SpatialHash.new(self)

func reactivate(coordinates:Vector2i):
	if coordinates == spatial_hash.hash_location:
		participants.clear()
		process_mode = Node.PROCESS_MODE_INHERIT
		monitoring = true
		count +=1
		visible = false
		print_debug("Battle number %s at previously contested %s" % [count+1, global_position])

func _on_body_entered(body:Node2D):
	active_fighters[body.faction].append(body)
	if not body in participants:
			participants.append(body)
	

func _on_body_exited(body:Node2D):
	active_fighters[body.faction].erase(body)
	body.action=&"move"
		
func _tick():
	if active_fighters[side_a].size() == 0:
		battle_over.emit(side_b)
		winner = side_b
		end_battle()
		return
	if active_fighters[side_b].size() == 0:
		battle_over.emit(side_a)
		winner = side_a
		end_battle()
		return
	
	battle(active_fighters[side_a],active_fighters[side_b])
	battle(active_fighters[side_b],active_fighters[side_a])
	

func battle(attacker:Array,defender:Array):
	for agent:Node2D in attacker:
		if agent is OverworldPlayer:
			continue
		agent.use_flow_field=false
		agent.action = &"attack"
		if not agent.target in defender or agent.target.overworld_hp <= 0:
			var target:PhysicsBody2D = defender.pick_random()
			agent.target = target
		if agent is OverworldAgent and agent.global_position.distance_squared_to(agent.target.global_position) < ATK_RANGE:
			var direction = agent.global_position.direction_to(agent.target.global_position)
			agent.linear_velocity = direction * agent.speed


func end_battle():
		damage_timer.stop()
		SpatialMap.update_control(spatial_hash.hash_location,winner)
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
		monitoring = false
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
		#queue_free()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,collision_shape.shape.size),Color.YELLOW * Color(1,1,1,0.2))
