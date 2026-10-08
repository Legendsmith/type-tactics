extends Control

@export_custom(0, "scene") var post_credits_scene: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var credits_container: VBoxContainer = $CreditsContainer


func _ready() -> void:
	for child in credits_container.get_children():
		if child is VBoxContainer:
			child.visible = false
			child.self_modulate = Color(1.0, 1.0, 1.0, 0.0)


func _on_start_credits() -> void:
	animation_player.animation_finished.connect(end_credits.unbind(1))
	animation_player.play("Credits")


func _on_skip_requested() -> void:
	end_credits()


func end_credits() -> void:
	#GameManager.change_scene(post_credits_scene)
	pass


func open_link(link: String) -> void:
	OS.shell_open(link)
