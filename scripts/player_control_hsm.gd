extends LimboHSM
@export var interact_action:GUIDEAction = load("uid://gx2rk7280sq0")
@export var _active:bool = true:
	set(new_value):
		_active = new_value
		if is_inside_tree():
			set_active(new_value)
			owner.bt_player.active = !new_value


@onready var idle_state:LimboState = $IdleState
@onready var move_state:LimboState = $MoveState

func _ready():
	configure_hsm()
	await owner.ready
	initialize(owner,owner.bt_player.blackboard)
	interact_action.just_triggered.connect(agent.interact)
	if _active:
		owner.bt_player.active=false
		set_active(true)
	#active_state_changed.connect(print_state) #uncomment for debug

func configure_hsm():
	add_transition(move_state,idle_state,move_state.EVENT_FINISHED)
	add_transition(idle_state,move_state,&"move")

#func print_state(current,previous):
#	print_debug("state changed to %s from %s" % [current,previous]) 
