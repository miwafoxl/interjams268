class_name B3DMovement extends Behaviour

@export var speed: float = 600.0
@export var heavyness: float = 0.67
@export var acceleration: float = 1.0

var body: CharacterBody3D = null
var vector: Vector3 = Vector3.ZERO

func init() -> void:
	body = actor as CharacterBody3D

func condition_physics(_delta: float) -> bool:
	return (vector != Vector3.ZERO) or body.velocity != Vector3.ZERO

func action_physics(_delta: float) -> void:
	var _velocity: Vector3 = lerp(body.velocity, \
		speed * vector, 1 - clampf(heavyness, 0, 0.98))
	if not _velocity.distance_to(Vector3.ZERO) < 0.5:
		body.set_velocity(_velocity)
	else:
		body.set_velocity(Vector3.ZERO)
	body.move_and_slide()
