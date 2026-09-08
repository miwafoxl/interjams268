class_name BHealth extends Behaviour

const MINIMUM_HEALTH: int = 0
const MAXIMUM_HEALTH: int = 100

var hp: int = 10
var super_hp: int = 0
var is_immortal: bool = false
var allow_superheal: bool = false
var last_chance_trigger: bool = false

func init() -> void:
	hp = flags.get("hp", hp)
	super_hp = flags.get("super_hp", super_hp)
	is_immortal = flags.get("is_immortal", is_immortal)

func modify_hp(amount: int, by: String = "", last_chance: bool = true) -> void:
	if amount + hp > MAXIMUM_HEALTH:
		if allow_superheal:
			hp = MINIMUM_HEALTH
			super_hp += 1
		else:
			hp = MAXIMUM_HEALTH
			last_chance_trigger = false
		event.emit("max_health")
	elif amount + hp <= MINIMUM_HEALTH:
		if super_hp > 0:
			super_hp -= 1
			hp = MAXIMUM_HEALTH
		else:
			if last_chance:
				last_chance_trigger = true
				hp = MINIMUM_HEALTH + 1
				event.emit("damage", by)
			else:
				hp = MINIMUM_HEALTH
				event.emit("min_health") # Death
	else:
		if amount + hp > hp: event.emit("heal", by)
		if amount + hp < hp: event.emit("damage", by)
		hp = amount + hp
	
