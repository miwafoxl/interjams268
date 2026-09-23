class_name Weapon extends Node

const DEFAULT_CAT: String = "fishgame"
const UNKNOWN_ITEM_TR: String = "GAME.ITEMS.UNKNOWN"

static var registered_weapons: Dictionary = {}

static func is_weapon_registered(item_id: String) -> bool:
	return registered_weapons.has(item_id)

func register_weapon(cat: String, item_id: String, stats: Dictionary) -> void:
	var _weapon_id: String = "%s:%s" % [cat, item_id]
	if registered_weapons.has(_weapon_id):
		push_warning("[Weapon] Attempt to register already registered weapon '%s'" % _weapon_id)
		return
	registered_weapons.set(_weapon_id, stats)
	print("[Weapon] Registered '%s' (%s)" % [_weapon_id, item_id.capitalize()])

func _ready() -> void:
	register_weapon(DEFAULT_CAT, "tinpia", {
			"bullet_scn_path": "res://game/scenes/bullet/generic.tscn", 
			"bullet_damage": 1.0,
			"bullet_speed": 1.0,
			"bullet_gravity": 1.0,
			"cadence": 1.0,
		})
