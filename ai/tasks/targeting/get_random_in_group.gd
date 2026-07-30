#*
#* get_random_in_group.gd
@tool
extends BTAction
## Stores a random node in the [member group] on the blackboard,
## returning [code]SUCCESS[/code]. [br]
## Returns [code]FAILURE[/code] if the group contains 0 nodes.

## Name of the SceneTree group.
@export var group_var: StringName

## Blackboard variable in which the task will store the acquired node.
@export var output_var: StringName = &"target"


func _generate_name() -> String:
	return "Get Random Node In Group \"%s\"  ➜%s" % [
		group_var,
		LimboUtility.decorate_var(output_var)
		]

func _tick(_delta: float) -> Status:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(blackboard.get_var(group_var))
	if nodes.size() == 0:
		return FAILURE
	blackboard.set_var(output_var, nodes.pick_random())
	return SUCCESS
