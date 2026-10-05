class_name GEntity extends GameObject

signal b_inited
signal min_health_reached

@onready var rayc: RayCast3D = %"RAYC AIM"
@onready var head: Node3D = %HEAD
@onready var cam: Camera3D = %CAM
@onready var gspammer: GameObject = %SPAMMER

var movement: B3DMovement = null
var health: BHealth = null
var inventory: BInventory = null
var input: BInput = null
var spammer: B3DSpammer = null
var is_player: bool = false

func after_init() -> void:
	movement = get_behaviour("B3DMovement")
	health = get_behaviour("BHealth")
	inventory = get_behaviour("BInventory")
	spammer = gspammer.get_behaviour("B3DSpammer")
	spammer.spawn_node = SceneMaster.get_current()
	spammer.origin_node = %ORIGIN
	if not health.event.is_connected(health_event):
		health.event.connect(health_event)
	b_inited.emit()

func give_item(item_id: String, meta: Dictionary = {}, q: int = 1) -> bool:
	if Items.is_item_registered(item_id):
		var _added_q: int = inventory.add_item_q(item_id, meta, q)
		if is_player and _added_q > 0:
			if Items.get_item_type(item_id) == Items.Type.WEAPON:
				inventory.select_item_id(item_id)
			RoamPlayUI.toast_item(item_id, _added_q)
		return true
	return false

func remove_item_q(item_id: String, q: int = 1) -> void:
	return inventory.remove_item_q(item_id, q)

func add_player_controls() -> void:
	if not input == null: # PATCH: Remove me
		input.set_enabled(false)
	insert_behaviour(BPlayerInput.new())
	input = get_behaviour("BPlayerInput")
	inventory = Progression.player_inventory
	ViewModel.provide_behaviours(inventory, input)
	cam.make_current()
	is_player = true
	
	if not inventory.event.is_connected(inventory_event):
		inventory.event.connect(inventory_event)

func add_cpu_controls() -> void:
	# TODO: add remove_behaviour("BPlayerInput") to GameObject
	insert_behaviour(BInventory.new())
	inventory = get_behaviour("BInventory")
	cam.clear_current()
	is_player = false

	if not inventory.event.is_connected(inventory_event):
		inventory.event.connect(inventory_event)
	

#region HEALTH

func death() -> void:
	min_health_reached.emit()
	queue_free()

func change_hp(delta: int) -> void:
	health.modify_hp(delta)

func health_event(event: String, ..._args) -> void:
	match event:
		"max_health": pass
		"min_health": 
			death() # TODO: Placeholder
		"heal": pass
		"damage": pass

#endregion HEALTH

func inventory_event(event: String, ...args) -> void:
	match event:
		"selection_changed":
			var _item_id: String = args[0]
			match Items.get_item_type(_item_id):
				Items.Type.WEAPON:
					gspammer.set_enabled(true)
				_:
					gspammer.set_enabled(false)
	

func process(_delta: float) -> void:
	var _interact: Area3D = rayc.get_collider()
	if not input == null:
		movement.vector = (head.transform.basis * Vector3(input.move_normal.x, \
				input.jump, input.move_normal.y).normalized())
		spammer.spawn_vector = (head.global_position.direction_to(%AIM.global_position))
		if input.interact and _interact != null:
			var _b: B3DInteractable = GameObject.get_behaviour_from(_interact.get_parent(), "B3DInteractable")
			if not _b == null: _b.trigger()
		if is_player:
			var _player_input: BPlayerInput = input
			RoamPlayUI.can_interact = _interact != null
			GameUI.can_interact = _interact != null
			spammer.spamming = _player_input.fire
			head.rotate_y(-_player_input.aim_transformed.x)
			cam.rotate_x(-_player_input.aim_transformed.y)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-80), deg_to_rad(80))
