@icon("res://core/res/GameObject.svg")
class_name GameObject extends Node

const SELF_NODE_ACTOR: String = "self"

@warning_ignore("unused_signal")
signal behaviour_event(event: StringName)

@export var enabled: bool = true
@export var verbose: bool = false
@export var scripts: Array[GDScript]
@export var flags: Dictionary[String, Variant] = {}

# AUTO
var behaviours: Dictionary[String, Behaviour] = {}
var do_behaviour_init: bool = true 
# AUTO

 #region CONSOLE OUT

func _log_standard(message: String) -> void:
	if not verbose: return
	print("[GameObject]: %s" % [message])

func _log_warn(message: String) -> void:
	if not verbose: return
	push_warning("[GameObject]: %s" % [message])

func _log_err(message: String) -> void:
	printerr("[GameObject]: %s" % [message])

#endregion CONSOLE OUT
#region MANAGING GAMEOBJECT

## Set this GameObject enabled. A disabled GameObject will disable
## all its containing [Behaviour]s.
func set_enabled(enable: bool) -> void:
	enabled = enable

# TODO: This is slow as shi*!!!!!!!!!!!!!*
## Obtains the [GameObject] if it's present in [code]node[/code] and returns it.
## Returns [code]null [/code] if not found.[br]
## [codeblock lang=gdscript]
## # Does this node have Bullet behaviour?
## var object := GameObject.get_gameobject(some_node);
## var bullet_behaviour := object.get_behaviour("bullet");
## if not behaviours.is_empty(): # It must be a bullet...
## 		glass_break()  # Let's shatter!
## [/codeblock][br][br]
## You can also use [method GameObject.get_behaviour_from] or 
## [method GameObject.has_behaviour].
static func get_gameobject(object: Node) -> GameObject:
	if object is GameObject:
		return object as GameObject
	push_warning("Could not get GameObject from object %s" % object.to_string())
	return null

## Obtains a [Behaviour] from a [Node] that has [GameObject]. 
## Returns [code]null[/code] if GameObject isn't present in object.[br]
## [codeblock lang=gdscript]
## var bullet := GameObject.get_behaviour_from(some_node, &"bullet");
## if not bullet == null: # It must be a bullet...
## 		bullet.set_speed(36)  # How convenient
## [/codeblock]
static func get_behaviour_from(object: Node, tag: String) -> Behaviour:
	var _behaviour: Behaviour = null
	if object is GameObject:
		_behaviour = object.get_behaviour(tag)
	if _behaviour == null:
		push_warning("Could not get behaviour '%s' from object %s" % [tag, object.get_path()])
	return _behaviour

#endregion MANAGING GAMEOBJECT
#region MANAGING BEHAVIOURS

## Checks whether [code]behaviour_name[/code] is present in a [GameObject] of object. 
## Returns [code]false[/code] if behaviour was not found or GameObject isn't 
## present in object.[br]
## [codeblock lang=gdscript]
## var toxic: bool = GameObject.has_behaviour(some_node, "toxic");
## if toxic:
## 		self.poison()
## [/codeblock]
static func has_behaviour(object: Node, tag: String) -> bool:
	var _behaviour: Behaviour = null
	if object is GameObject:
		var _gameobject: GameObject = object as GameObject
		if not _gameobject.get_behaviour(tag) == null:
			return true
	return false

## Obtains a single behaviour that match [code]tag[/code]. Returns null
## if no match was found.
func get_behaviour(tag: String = "") -> Behaviour:
	return behaviours.get(tag, null)

## Obtains all behaviours that matches [code]expr[/code]. Returns an empty
## [Array] if none matched.
func get_behaviour_match(expr: String = "B*") -> Array[Behaviour]:
	var _selected: Array[Behaviour] = []
	for behaviour_tag: String in behaviours.keys():
		if behaviour_tag.match(expr):
			_selected.append(behaviours.get(behaviour_tag))
	return _selected

## Insert the behaviour [code]behaviour[/code] following the index [code]at_index[/code].
## If negative, the value will be considered from the end of the array.
func insert_behaviour(behaviour: Behaviour) -> void:
	var _script: GDScript = behaviour.get_script()
	var _name: String = _script.get_global_name()
	if _script == null:
		return
	add_script(_script, _name)
	_log_standard("Inserted behaviour '%s'" % _name)
	return 

## Updates the behaviour list based on the scripts array. Ran automatically by
## GameObject.
func preprocess_behaviours() -> int:
	var _size: int = scripts.size()
	if _size == 0: return -1
	for i in _size:
		var _script: GDScript = scripts[i]
		var _tag: String = _script.get_global_name()
		if not add_script(_script, _tag):
			_log_err("Script for '%s' at index %s does not extend class Behaviour" % [_tag, i])
	return 0

## Updates each behaviour with a new [code]actors[/code] value, then runs [code]init()[/code].
## This ensures that all behaviours have a reference to the actors array. It's ran
## automatically by [method GameObject.preprocess_behaviours] and other methods.
func init_behaviours(behaviour_array: Array[Behaviour]) -> void:
	after_reinit.call_deferred()
	for behaviour: Behaviour in behaviour_array:
		behaviour.actor = self
		behaviour.flags = flags.duplicate_deep()
		if not behaviour.event.is_connected(dispatch_event):
			behaviour.event.connect(dispatch_event)
		behaviour.init()
	

#endregion MANAGING BEHAVIOURS
#region EVENTS

func dispatch_event(event: StringName) -> void:
	behaviour_event.emit(event)
	
#endregion EVENTS
#region FLAGS

func set_local_flag(key: String, value: Variant, reinit_all: bool = false) -> bool:
	var _success: bool = flags.set(key, value)
	do_behaviour_init = reinit_all
	return _success

func remove_local_flag(key: String, reinit_all: bool = false) -> bool:
	var _success: bool = flags.erase(key)
	do_behaviour_init = reinit_all
	return _success

func set_behaviour_flag(behaviour: String, key: String, value: Variant, \
		reinit: bool = false) -> bool:
	var _behaviour: Behaviour = get_behaviour(behaviour)
	if _behaviour == null:
		return false
	return _behaviour.set_flag(key, value, reinit)

func remove_behaviour_flag(behaviour: String, key: String, reinit: bool = false) -> bool:
	var _behaviour: Behaviour = get_behaviour(behaviour)
	if _behaviour == null:
		return false
	return _behaviour.remove_flag(key, reinit)

#endregion FLAGS
#region BEHAVIOUR CLOCK

var tick: int = -1
func _process(delta: float) -> void:
	if tick == -1: return # Disable processing
	if do_behaviour_init:
		init_behaviours(behaviours.values())
		do_behaviour_init = false
	if not behaviours.is_empty():
		for _b: Behaviour in behaviours.values():
			if _b.enabled and _b.condition(delta): 
				_b.action(delta)
	tick += 1
	if tick > 1000:
		tick = 0
	process(delta)

func _physics_process(delta: float) -> void:
	if do_behaviour_init: return # Disable processing
	if not behaviours.is_empty():
		for _b: Behaviour in behaviours.values():
			if _b.enabled and _b.condition_physics(delta): 
				_b.action_physics(delta)
	physics_process(delta)

#endregion BEHAVIOUR CLOCK
#region SCRIPTS

func add_script(script: GDScript, tag: String) -> bool:
	var _node: Node = Node.new()
	_node.set_script(script)
	if _node is Behaviour:
		var _behaviour: Behaviour = _node
		if tag.validate_node_name():
			_behaviour.set_name(tag as StringName)
		behaviours.set(tag, _behaviour)
		add_child(_node, false, Node.INTERNAL_MODE_FRONT)
		return true
	return false

#endregion SCRIPTS
#region OVERRIDES

func _ready() -> void:
	# Transform scripts into Behaviours
	_log_standard("Logging GameObject at %s" % self.get_path())
	# Duplicate behaviours and pre-process before running
	if tick == -1:
		tick = preprocess_behaviours()
		after_init.call_deferred()
	
#endregion OVERRIDES
#region OVERRIDEABLES

func after_init() -> void:
	pass

func after_reinit() -> void:
	pass

@warning_ignore("unused_parameter")
func process(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func physics_process(delta: float) -> void:
	pass

#endregion OVERRIDEABLES
