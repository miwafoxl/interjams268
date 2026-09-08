class_name InputPromptText extends CenterContainer

@export var untranslated_string: StringName = &""
@export var action_name: String = &""

@onready var keybind: Label = %KEYBIND
@onready var prefix: Label = %PREFIX
@onready var suffix: Label = %SUFFIX

func _ready() -> void:
	var _translation: String = tr(untranslated_string)
	var _keybind: Array[InputEvent] = InputMap.action_get_events(action_name)
	if _keybind.is_empty():
		printerr("Failed to get input events for action '%s'" % action_name)
		keybind.set_text(tr("GAME.SETTINGS.UNBOUND_BIND"))
	else:
		for bind: InputEvent in _keybind:
			if bind is InputEventKey:
				keybind.set_text(OS.get_keycode_string(bind.get_physical_keycode_with_modifiers()))
				break # TODO: also implement for controllers InputJoystickButton
	prefix.set_text(_translation.get_slice(r"%s", 0))
	suffix.set_text(_translation.get_slice(r"%s", 1))
