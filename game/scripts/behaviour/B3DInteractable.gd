class_name B3DInteractable extends Behaviour

var trigger_on_overlap: bool = false
var trigger_callable: Callable = Callable()
var trigger_scene_swap: String = ""
var trigger_event: String = ""
var disable_after_trigger: bool = false
var collision_layer: int = 0b00000000_00000000_00000000_00001000
var collision_mask: int = 0b00000000_00000000_00000000_00000010

var area3d: Area3D = null
var last_collisors: Array[Node3D] = []

func init() -> void:
	trigger_on_overlap = flags.get("trigger_on_overlap", trigger_on_overlap)
	trigger_scene_swap = flags.get("trigger_scene_swap", trigger_scene_swap)
	trigger_callable = flags.get("trigger_callable", trigger_callable)
	trigger_event = flags.get("trigger_event", trigger_event)
	disable_after_trigger = flags.get("disable_after_trigger", disable_after_trigger)
	collision_layer = flags.get("collision_layer", collision_layer)
	collision_mask = flags.get("collision_mask", collision_mask)
	enable()

func condition(_delta: float) -> bool:
	if trigger_on_overlap and not area3d == null:
		var _collisors: Array[Node3D] = area3d.get_overlapping_bodies()
		if not _collisors.is_empty():
			last_collisors = _collisors
			return true
	return false

func action(_delta: float) -> void:
	trigger()

func enable() -> void:
	var _area3d: Area3D = Area3D.new()
	var _col3d: CollisionShape3D = null
	for child: Variant in actor.get_children(false):
		if child is CollisionShape3D:
			_col3d = child.duplicate()
			_col3d.set_name(&"B3DInteractableCollisor")
	if _col3d == null:
		printerr("B3DInteractable at path '%s': Parent has no CollisionShape3D." % self.get_path())
		return
	_area3d.set_collision_layer(collision_layer)
	_area3d.set_collision_mask(collision_mask)
	actor.add_child(_area3d)
	_area3d.add_child(_col3d)
	area3d = _area3d
	

func trigger() -> void:
	if trigger_callable.is_valid():
		trigger_callable.call_deferred()
	if not trigger_scene_swap.is_empty():
		SceneMaster.swap_to_scene = trigger_scene_swap
	if not trigger_event.is_empty():
		event.emit(trigger_event, last_collisors)
	if disable_after_trigger:
		area3d.queue_free()
