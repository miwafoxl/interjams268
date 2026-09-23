class_name B3DSpammer extends Behaviour


# Flags
var spamming: bool = false
var spawn_node: Node = null # World scene
var spawn_vector: Vector3 = Vector3.FORWARD
var cadence: int = 5 # Ticks
var spam_scn: String = ""
var max_instances: int = 50
var collision_layer: int = -1
var collision_mask: int = -1
var call_method_name: StringName = &""
var call_method_args: Array = []

# Managed by B3DSpammer
var origin_node: Node3D = null
var instances: Array[Node3D] = []
var counting: int = 0
var checking: int = 0
var scn: PackedScene = null

func init() -> void:
	cadence = flags.get("cadence", cadence)
	max_instances = flags.get("max_instances", max_instances)
	spam_scn = flags.get("spam_scn", spam_scn)
	collision_layer = flags.get("collision_layer", collision_layer)
	collision_mask = flags.get("collision_mask", collision_mask)
	call_method_name = flags.get("call_method_name", call_method_name)
	call_method_args = flags.get("call_method_args", call_method_args)
	if origin_node == null: 
		origin_node = actor
	if spam_scn.is_absolute_path():
		scn = load(spam_scn) # TODO: Cache loaded spam_scn
	else:
		push_warning("[B3DSpammer] Path '%s' is not a valid path" % spam_scn)

func condition_physics(_delta: float) -> bool:
	var _instances: int = instances.size()
	if _instances > 0:
		if instances[checking] == null: # Goes around the instances array to cleanup entries
			instances.remove_at(checking) # that have been freed
		if checking >= _instances - 1:
			checking = 0
	counting = min(counting + 1, 1000)
	if spamming and counting >= cadence:
		counting = 0
	return true

func condition(_delta: float) -> bool:
	return spamming and (not scn == null) and \
			(not spawn_node == null) and \
			(counting == 0)

func action(_delta: float) -> void:
	if instances.size() + 1 > max_instances:
		if not instances[0] == null:
			instances[0].queue_free()
		instances.pop_front()
	
	var _scn: GBullet = scn.instantiate()
	if not call_method_name.is_empty() and _scn.has_method(call_method_name):
		_scn.callv(call_method_name, call_method_args)
	instances.append(_scn)
	spawn_node.add_child(_scn)
	_scn.global_position = origin_node.global_position
	if collision_layer > 0: _scn.collision_layer = collision_layer
	if collision_mask > 0: _scn.collision_mask = collision_mask
	if _scn.has_method(&"set_vector"):
		_scn.set_vector(spawn_vector)
	
