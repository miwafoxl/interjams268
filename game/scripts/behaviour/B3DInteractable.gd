class_name B3DInteractable extends Behaviour

var trigger_callable: Callable = Callable()
var trigger_scene_swap: String = ""
var trigger_event: String = ""
var disable_after_trigger: bool = false
var collision_layer: int = 0b00000000_00000000_00000000_00001000
var collision_mask: int = 0b00000000_00000000_00000000_00000010

var area3d: Area3D = null

func init() -> void:
	trigger_scene_swap = flags.get("trigger_scene_swap", trigger_scene_swap)
	trigger_callable = flags.get("trigger_callable", trigger_callable)
	trigger_event = flags.get("trigger_event", trigger_event)
	disable_after_trigger = flags.get("disable_after_trigger", disable_after_trigger)
	collision_layer = flags.get("collision_layer", collision_layer)
	collision_mask = flags.get("collision_mask", collision_mask)
	var _parent: Node3D = get_parent()
	var _area3d: Area3D = Area3D.new()
	var _col3d: CollisionShape3D = null
	for child: Node3D in _parent.get_children(false):
		if child is CollisionShape3D:
			_col3d = child.duplicate()
	if _col3d == null:
		print("B3DInteractable at %s: Parent has no CollisionShape3D." % self.get_path())
		return
	_area3d.set_collision_layer(collision_layer)
	_area3d.set_collision_mask(collision_mask)
	_parent.add_child(_area3d)
	_area3d.add_child(_col3d)
	area3d = _area3d

func trigger() -> void:
	if trigger_callable.is_valid():
		trigger_callable.call_deferred()
	if not trigger_scene_swap.is_empty():
		SceneMaster.swap_to_scene = trigger_scene_swap
	if not trigger_event.is_empty():
		event.emit(trigger_event)
	if disable_after_trigger:
		area3d.set_monitorable(false)
