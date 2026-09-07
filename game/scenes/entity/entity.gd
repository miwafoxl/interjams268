class_name GEntity extends GameObject

var movement: B3DMovement = null
var input: BInput = null

func after_init() -> void:
	movement = get_behaviour("B3DMovement")

func add_player_controls() -> void:
	if not input == null:
		input.set_enabled(false)
	insert_behaviour(BPlayerInput.new())
	input = get_behaviour("BPlayerInput")

func add_cpu_controls() -> void:
	print_debug("Not implemented")

func process(_delta: float) -> void:
	if not input == null:
		movement.vector = ($HEAD.transform.basis * Vector3(input.move_normal.x, \
				input.jump, input.move_normal.y).normalized())
		if input is BPlayerInput:
			var _player_input: BPlayerInput = input
			# TODO: maybe turn the head into a GameObject "GPlayerPOV"?
			# TODO: GPlayerPOV.set_current(true)
			$HEAD.rotate_y(-_player_input.aim_transformed.x)
			$HEAD/CAM.rotate_x(-_player_input.aim_transformed.y)
			$HEAD/CAM.rotation.x = clamp($HEAD/CAM.rotation.x, deg_to_rad(-80), deg_to_rad(80))
