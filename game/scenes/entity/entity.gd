class_name GEntity extends GameObject

@onready var rayc: RayCast3D = %"RAYC AIM"
@onready var head: Node3D = %HEAD
@onready var cam: Camera3D = %CAM

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
	cam.make_current()
	is_player = true

func add_cpu_controls() -> void:
	print_debug("Not implemented")
	is_player = false
	cam.clear_current()

func health_event(event: String, _by: String) -> void:
	match event:
		"max_health": pass
		"min_health": 
			queue_free() # TODO: Placeholder
		"heal": pass
		"damage": pass

func process(_delta: float) -> void:
	var _interact: Area3D = rayc.get_collider()
	RoamPlayUI.can_interact = _interact != null
	if not input == null:
		movement.vector = (head.transform.basis * Vector3(input.move_normal.x, \
				input.jump, input.move_normal.y).normalized())
		if input.interact and _interact != null:
			var _b: B3DInteractable = GameObject.get_behaviour_from(_interact.get_parent(), "B3DInteractable")
			if not _b == null: _b.trigger()
		if is_player:
			var _player_input: BPlayerInput = input
			head.rotate_y(-_player_input.aim_transformed.x)
			cam.rotate_x(-_player_input.aim_transformed.y)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-80), deg_to_rad(80))
