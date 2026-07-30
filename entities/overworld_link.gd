extends Path2D

signal request_contested(faction:StringName,destination:int)

var navigation_link_player:NavigationLink2D
var navigation_link_enemy:NavigationLink2D

var skip_frames:int = 4
@onready var tick_offset:int = randi() % 60

var contested:bool = false
## Exceptions to the hit.
var exceptions:Array[Node2D] =[]

static var path_follower:PackedScene = load("uid://cb50uu7l62pct")

func _ready() -> void:
	navigation_link_player = configure_navigation_link($NavigationLinkPlayer)
	navigation_link_enemy = configure_navigation_link($NavigationLinkEnemy)
	#navigation_link_player.set_navigation_layer_value(Overworld.NAV_LAYER_PLAYER,true)
	#navigation_link_enemy.set_navigation_layer_value(Overworld.NAV_LAYER_ENEMY,true)
	$ExitArea.position = curve.get_point_position(curve.point_count-1)
	
func configure_navigation_link(nav_link:NavigationLink2D) ->NavigationLink2D:
	nav_link.navigation_layers = 0
	nav_link.start_position = curve.get_point_position(0)
	nav_link.end_position = curve.get_point_position(curve.point_count-1)
	nav_link.bidirectional = false
	return nav_link

func _process(delta: float) -> void:
	if (Engine.get_physics_frames() + tick_offset) % (skip_frames + 1) == 0:
		pass

func reset_exception(body:Node2D):
	if body in exceptions:
		exceptions.erase.call_deferred(body)

func check_contested(faction:StringName,_destination:int):
	contested =false
	request_contested.emit(faction)

func depart():
	var new_follow:OverworldPathFollow = path_follower.instantiate()
	add_child(new_follow)
	new_follow.progress_ratio = 0.0
	
