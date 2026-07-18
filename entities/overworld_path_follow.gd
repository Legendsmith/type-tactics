class_name OverworldPathFollow
extends PathFollow2D
## Speed in percent
var speed:float = 0.1
var faction:StringName
var stop_at:float = 1

var passengers:Array[Node2D]
var merging:bool = false
var waiting:bool = true
var arrived:bool = false

var fighting:bool = false
var fighting_target:Node2D

var atk:int = 0

func _ready() -> void:
	get_parent().request_contested.connect(on_request_contested)
	%Area2D.area_entered.connect(on_area_entered)

func on_request_contested(checking_faction:StringName,checking_destination:int):
	# The destinations must be opposed otherwise it's a pursuit.
	if fighting:
		get_parent().contested = true


func _physics_process(delta: float) -> void:
	if fighting:
		attack_other(fighting_target,delta)
		get_passenger_power()
	elif progress_ratio >=1.0 and not arrived:
		arrived = true
		passengers.back().freeze = false
	else:
		move_toward(progress_ratio,stop_at,speed*delta)
		

func on_area_entered(area:Area2D):
	var area_parent:Node2D = area.get_parent()
	if area_parent is OverworldPathFollow:
		if area_parent.faction == faction and area_parent.progress_ratio > progress_ratio and not area_parent.merging:
			merging = true
			%Area2D.set_deferred(&"monitoring" ,false)
			%Area2D.set_deferred(&"monitorable" , false)
			merge(area_parent)
		if area.faction != faction:
			fighting = true
			fighting_target = area_parent

func attack_other(target:OverworldPathFollow,delta:float):
	for passenger:OverworldAgent in passengers:
		target.passengers.pick_random().recieve_damage(passenger,passenger.overworld_atk,delta)


func start_transport():
	waiting = false
	arrived = false
	get_passenger_power()


func merge(target:Node2D):
	for node:Node2D in passengers:
		node.reparent(target)
	passengers.clear()
	await get_tree().physics_frame
	queue_free()


func body_exited(body:Node2D):
	if arrived and is_ancestor_of(body):
		passengers.erase(body)
		passengers.back().freeze = false

func on_area_exited(area:Area2D):
	var area_parent:Node2D = area.get_parent()
	if area_parent is OverworldPathFollow:
		if area_parent == fighting_target:
			fighting = false


func on_body_entered(body:Node2D):
	if waiting and body is OverworldAgent and not body in passengers:
		passengers.append(body)
		body.reparent(self)
		body.freeze = true


func get_passenger_power():
	atk = 0
	for passenger:OverworldAgent in passengers:
		atk += passenger.overworld_atk
