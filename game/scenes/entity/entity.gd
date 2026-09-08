class_name GEntity extends GameObject

@export var rayc_interact: RayCast3D

var movement: B3DMovement = null
var health: BHealth = null
var input: BInput = null
var is_player: bool = false


func after_init() -> void:
	movement = get_behaviour("B3DMovement")
	health = get_behaviour("BHealth")
	if not health.event.is_connected(health_event):
		health.event.connect(health_event)

func add_player_controls() -> void:
	if not input == null: # PATCH: Remove me
		input.set_enabled(false)
	insert_behaviour(BPlayerInput.new())
	input = get_behaviour("BPlayerInput")
	is_player = true

func add_cpu_controls() -> void:
	print_debug("Not implemented")
	is_player = false

func health_event(event: String, _by: String) -> void:
	match event:
		"max_health": pass
		"min_health": 
			queue_free() # TODO: Placeholder
		"heal": pass
		"damage": pass

func process(_delta: float) -> void:
	if not input == null:
		movement.vector = ($HEAD.transform.basis * Vector3(input.move_normal.x, \
				input.jump, input.move_normal.y).normalized())
		if is_player:
			var _player_input: BPlayerInput = input
			# TODO: maybe turn the head into a GameObject "GPlayerPOV"?
			# TODO: GPlayerPOV.set_current(true)
			$HEAD.rotate_y(-_player_input.aim_transformed.x)
			$HEAD/CAM.rotate_x(-_player_input.aim_transformed.y)
			$HEAD/CAM.rotation.x = clamp($HEAD/CAM.rotation.x, deg_to_rad(-80), deg_to_rad(80))
