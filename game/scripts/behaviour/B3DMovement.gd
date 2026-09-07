class_name B3DMovement extends Behaviour

const JUMP_THRESHOLD: float = 5.0

@export var speed: float = 10.0
@export var heavyness: float = 0.67
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.806)

var body: CharacterBody3D = null
var vector: Vector3 = Vector3.ZERO

func init() -> void:
	speed = flags.get("speed", speed)
	heavyness = flags.get("heavyness", heavyness)
	body = actor as CharacterBody3D

func condition_physics(_delta: float) -> bool:
	return (vector != Vector3.ZERO) or body.velocity != Vector3.ZERO

func action_physics(_delta: float) -> void:
	var _velocity: Vector3 = lerp(body.velocity, \
		speed * vector, 1 - clampf(heavyness, 0, 0.98))
	if not _velocity.distance_to(Vector3.ZERO) < 0.5:
		body.set_velocity(Vector3(_velocity.x, body.velocity.y, _velocity.z))
	else:
		body.set_velocity(Vector3(0, body.velocity.y, 0))
	if body.is_on_floor() and (body.velocity.y < JUMP_THRESHOLD):
		body.velocity.y += vector.y * speed
	body.move_and_slide()

func _physics_process(delta: float) -> void:
	if not body == null and not body.is_on_floor():
		body.velocity.y -= gravity * delta
