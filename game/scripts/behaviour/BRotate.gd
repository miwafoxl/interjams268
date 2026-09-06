class_name BRotate extends Behaviour

var amount: float = 0.05
var rotating: Sprite2D = actor
var multiplier: int = 1

func init() -> void:
	amount = flags.get("amount", amount)
	multiplier = -1 if flags.has("reverse") else 1
	if rotating == null:
		rotating = actor
	
func condition(_delta: float) -> bool:
	return true

func action(_delta: float) -> void:
	rotating.rotate(amount * multiplier)
