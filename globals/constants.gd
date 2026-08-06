class_name Constants

#region Program Navigation

const MAIN_MENU:String = "uid://dea4j22alycht"

#region Physics & Groups

const PLAYER_ENTITY := &"player_ent"
const PLAYER_GROUP := &"player"
const ENEMY_GROUP := &"opponent"
const PHYS_TERRAIN := 1
const PHYS_HAZARD := 2
const PHYS_INTERACT := 3
const FACTION_PHYSLAYER_OFFSET := 4
const PLAYER_PHYSICS_LAYER:= 3
const AGENT_MAX_LINEAR_DAMP := 4.0

#endregion

#region Overworld

const OVERWORLD_BATTLE_TICK:float = 0.5
const OVERWORLD_DAMAGE_VARIANCE:float = 0.85
const OVERWORLD_MAX_ATTACK_CHARGE:float = 0.5
const OVERWORLD_PHYSICS_QUERY_SHAPE_RESOURCE:String = "uid://diaqls5q1pn3"
const OVERWORLD_TRAFFIC_EASE:float = -2.0
#endregion

#region Navigation

const NAV_LAYER_ALL := 1
const AVOIDANCE_OFFSET := 0
const FLOW_FIELD_GROUP := &"flow_field_target"
const SPATIAL_HASH_SIZE := 512

#endregion


#region Audio Bus Information

const MASTER_BUS: StringName = &"Master"
const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"Sfx"
const CHARACTER_VOICING: StringName = &"Character Voicing"

const MASTER_BUS_INDEX: int = 0
const MUSIC_BUS_INDEX: int = 1
const SFX_BUS_INDEX: int = 2
const CHARACTER_VOICING_INDEX: int = 3

#endregion
