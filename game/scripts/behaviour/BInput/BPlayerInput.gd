class_name BPlayerInput extends BInput

var mouse_smoothness: float = 0.7
var mouse_sensitivity: float = 0.005
var aim_transformed: Vector2 = Vector2.ZERO

func init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func condition(_delta: float) -> bool:
	# Gets the movement vector normalized and if player is firing
	move_normal = Input.get_vector("move_left", "move_right", \
		"move_forwards", "move_backwards")
	jump = Input.is_action_pressed("jump")
	interact = Input.is_action_pressed("interact")
	fire = Input.is_action_pressed("fire")
	alt_fire = Input.is_action_pressed("alt_fire")
	# Recapture mouse if focus was lost
	if fire and not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Uncaptures mouse if ESC is pressed
	if Input.is_action_pressed("unfocus"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Smoothes the aim
	aim_transformed = lerp(aim_transformed, \
		mouse_sensitivity * aim_normal, 1 - clampf(mouse_smoothness, 0, 0.98))
	aim_normal = Vector2.ZERO # Prevents self-moving mouse bug
	return true

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion and \
	Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var _mouse: InputEventMouseMotion = ev
		aim_normal = _mouse.relative
