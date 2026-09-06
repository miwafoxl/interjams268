class_name SoundBlaster extends Node

const LOG_VERBOSE: bool = true
const SOUND_MAX_QUOTA: int = 16

@export var sound_presets: Dictionary[String, AudioEvent]
@export var music_presets: Dictionary[String, AudioEvent]

static var loaded_sounds: Dictionary[String, AudioEvent]
static var sound_queue: Array[String] = []


#region CONSOLE OUT

static func _log_standard(message: String) -> void:
	if not LOG_VERBOSE: return
	print("[Audio]: %s" % message)

static func _log_warn(message: String) -> void:
	if not LOG_VERBOSE: return
	push_warning("[Audio]: %s" % message)

static func _log_err(message: String) -> void:
	printerr("[Audio]: %s" % message)

#endregion CONSOLE OUT
#region LOADING/UNLOADING

static func load_sounds(sounds: Dictionary[String, AudioEvent]) -> void:
	for sound_name: String in sounds.keys():
		if loaded_sounds.has(sound_name):
			_log_standard("Overwriting already loaded sound or music '%s'" % sound_name)
		loaded_sounds.set(sound_name, sounds[sound_name])

#endregion LOADING/UNLOADING
#region PLAYING

var tick: int = 0
func _process(_delta: float) -> void:
	if sound_queue.size() > 0:
		play(sound_queue.front())
		sound_queue.pop_front()
		tick += 1
	else:
		tick = 0

func play(sound_name: String) -> void:
	var _player: AudioStreamPlayer = null
	var _str: AudioStream = null
	if not loaded_sounds.has(sound_name):
		_log_warn("Can't play sound event '%s' - No such sound loaded" % sound_name)
		return
	var _event: AudioEvent = loaded_sounds.get(sound_name)
	var _index: int = randi_range(0, _event.stream_list.stream_count)
	_str = _event.stream_list.get_list_stream(_index)
	_player = AudioStreamPlayer.new()
	_player.set_stream(_str)
	_player.set_bus(_event.to_bus())
	add_child(_player)
	_player.play()

static func queue_play(sound_name: String) -> void:
	if sound_queue.size() < SOUND_MAX_QUOTA:
		sound_queue.append(sound_name)

static func cancel_play(sound_name: String) -> void:
	var _has_sound: Callable = func(s: String) -> bool:
		return s == sound_name
	sound_queue.filter(_has_sound)

#endregion PLAYING
#region OVERRIDES

func _ready() -> void:
	pass

#endregion OVERRIDES
