extends Unit

func create_from_unit_def(def:UnitDef) -> void:
	display_name = def.unit_name
	_max_equip = def.max_equip
	%MainSprite.texture = def.sprite
	types = def.types
	#ability = def.ability
	base_techniques = def.base_techniques.duplicate()
	attribute_base = def.attribute_base.duplicate()

func battle_animation(animation_name:StringName) -> AnimationPlayer:
	$AnimationPlayer.play(animation_name)
	return $AnimationPlayer


