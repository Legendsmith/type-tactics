extends Node
const FACTION_FILEPATH = "res://data/factions.json"

var faction_list:Dictionary[StringName,Faction]
var master_phys:int = 0
var master_attack:int = 0
var master_avoid:int = 0


func _init():
	var fac_defs:Dictionary = load_faction_definitions()
	# if mods ever happen code inserted here can add them to the definition dictionary
	build_faction_data(fac_defs)


func load_faction_definitions() ->Dictionary:
	var faction_data = JSON.parse_string(
		FileAccess.open(FACTION_FILEPATH, FileAccess.READ).get_as_text()
	)
	if faction_data == null or not faction_data is Dictionary:
		push_error("Failed to Parse Faction Data!")
	return faction_data

func build_faction_data(faction_data:Dictionary) -> void:
	# Initiate the counting indexes
	var i_phys:int = Constants.FACTION_PHYSLAYER_OFFSET
	var i_nav:int = 0
	var i_avoid:int = Constants.AVOIDANCE_OFFSET
	# Variables for the master masks
	master_phys = 0
	master_attack = 0
	master_avoid = 0
	# Buld the actual definitions and masks.
	for entry in faction_data:
		var new_fac = Faction.new()
		new_fac.name = faction_data[entry]
		new_fac.physics_layer = (1 << i_phys) # What phys layer are our dudes on
		new_fac.attack_layer = (1 << i_phys+1) # what layer are our attacks on
		new_fac.nav_layer = Constants.NAV_LAYER_ALL | (1 << i_nav) # Our exclusive navigation layer
		new_fac.avoid_own = (1 << i_avoid) ## Avoid own areas (congested)
		faction_list[entry] = new_fac
		master_phys = master_phys | new_fac.physics_layer
		master_avoid = master_avoid | new_fac.avoid_own
		master_attack = master_attack | new_fac.attack_layer
		#
		i_phys += 2
		i_nav += 1
		i_avoid +=1
	
	# Build the derived masks now the base and master masks are computed.
	for faction:Faction in faction_list.values():
		faction.physics_mask = master_phys & ~faction.physics_layer # Take the master bitmask (all used phys layers) and just remove our layer from it. This is done by performing a NOT  
		faction.defense_mask = master_attack & ~faction.attack_layer # Take the master bitmask for all attacks (all used attack phys layers) and remove our attack layer from it.
		faction.avoid_enemy = master_avoid & ~faction.avoid_own # Remove our avoidance layer from the master avoidance bitmask and remove ours again.


class Faction:
	extends Resource
	var name: String
	#physics
	## Physics layer for our guys
	var physics_layer: int
	## Physics mask for our guys and attacks
	var physics_mask: int
	## Physics layer for our attacks
	var attack_layer: int
	## Physics layer for our defenses (shields, etc)
	var defense_mask:int 
	#navigation
	var nav_layer: int
	var avoid_own: int
	var avoid_enemy: int
