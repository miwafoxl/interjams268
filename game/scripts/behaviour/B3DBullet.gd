class_name B3DBullet extends Behaviour

var body: AnimatableBody3D = null
var speed: float = 50.0
var gravity: float = 0.0
var vector: Vector3 = Vector3.FORWARD

func init() -> void:
	body = flags.get("body", actor)
	speed = flags.get("speed", speed)
	gravity = flags.get("gravity", gravity)
	vector = flags.get("vector", vector)
	
func condition_physics(_delta: float) -> bool:
	if vector.is_zero_approx():
		queue_free()
	return not body == null

func action_physics(delta: float) -> void:
	var _collision: KinematicCollision3D = body.move_and_collide((vector * speed) * delta)
	if not _collision == null:
		event.emit("collision", _collision)
	if gravity > 0:
		vector.move_toward(Vector3(0, gravity, 0), delta)
