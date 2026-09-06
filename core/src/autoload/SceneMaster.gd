class_name SceneMaster extends Node

const LOG_VERBOSE: bool = true

@export var autoload_preset_at_startup: String = "default"
@export var preset_scenes: Dictionary[String, PackedScene] = {}

static var current_scene: WeakRef = null # -> Node
static var loaded_scenes: Dictionary[String, PackedScene] = {}

#region CONSOLE OUT

static func _log_standard(message: String) -> void:
	if not LOG_VERBOSE: return
	print("[Scene]: %s" % message)

static func _log_warn(message: String) -> void:
	if not LOG_VERBOSE: return
	push_warning("[Scene]: %s" % message)

static func _log_err(message: String) -> void:
	printerr("[Scene]: %s" % message)

#endregion CONSOLE OUT
#region SCENE MANAGING 

static func get_current() -> Node:
	if current_scene == null: return null
	return current_scene.get_ref() as Node

func swap_scene(loaded_scene: String) -> bool:
	var _scene: PackedScene = loaded_scenes.get(loaded_scene, null)
	var _new: Node = null
	if not loaded_scenes.has(loaded_scene) or _scene == null:
		_log_warn("Failed to swap to scene '%s' - No such scene loaded" % loaded_scene)
		return false
	unload_current()
	_new = _scene.instantiate()
	current_scene = weakref(_new)
	var _main: Node = get_parent()
	_main.add_child.call_deferred(_new)
	_log_standard("Swapping to scene '%s'" % loaded_scene)
	return true
	
func load_scene_path(scene_name: String, path: String, swap: bool = false) -> bool:
	var _scn: PackedScene = load(path)
	if _scn == null:
		_log_warn("Failed to load scene '%s'" % scene_name)
		return false
	if loaded_scenes.has(scene_name):
		_log_standard("Overwriting already loaded scene '%s'" % scene_name)
	loaded_scenes.set(scene_name, _scn)
	if swap: swap_scene(scene_name)
	return true

static func load_scenes(scenes: Dictionary[String, PackedScene]) -> void:
	for scene_name: String in scenes.keys():
		if loaded_scenes.has(scene_name):
			_log_standard("Overwriting already loaded scene '%s'" % scene_name)
		loaded_scenes.set(scene_name, scenes[scene_name])

static func unload_current() -> void:
	var _cur: Node = get_current()
	if not _cur == null: 
		_cur.queue_free()
		_log_standard("Unloading current scene")

static func unload_scene(scene_name: String) -> void:
	if loaded_scenes.has(scene_name):
		loaded_scenes.erase(scene_name)
		_log_standard("Unloaded scene '%s'" % scene_name)

#endregion SCENE MANAGING
#region OVERRIDES

func _ready() -> void:
	load_scenes(preset_scenes)
	if not autoload_preset_at_startup.is_empty():
		swap_scene(autoload_preset_at_startup)

#endregion OVERRIDES
