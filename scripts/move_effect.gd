extends BattleEffect

func execute(source:Unit,target:Node) -> bool:
	source.global_position = target.global_position
	return true
