class_name BHealth extends Behaviour

const MINIMUM_HEALTH: int = 0
const MAXIMUM_HEALTH: int = 100

var hp: int = 10
var is_immune: bool = false

func init() -> void:
	hp = flags.get("hp", hp)
	is_immune = flags.get("is_immune", is_immune)

func modify_hp(amount: int, by: String = "") -> void:
	if amount + hp > MAXIMUM_HEALTH:
		hp = MAXIMUM_HEALTH
		event.emit("max_health")
	elif amount + hp < MAXIMUM_HEALTH:
		hp = MINIMUM_HEALTH
		event.emit("min_health") # Death
	else:
		if amount + hp > hp: event.emit("heal", by)
		if amount + hp < hp: event.emit("damage", by)
		hp = amount + hp
	
