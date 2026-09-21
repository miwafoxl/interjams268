class_name TemperatureMeter extends PanelContainer


@export_color_no_alpha var temperature_ok: Color
@export_color_no_alpha var temperature_under: Color
@export_color_no_alpha var temperature_bad: Color

@export var description: String = ""
@export var temperature: float = 0.0
@export var convert_to: int = 1
@export var good_range_min: float = 0
@export var good_range_max: float = 1

func set_range(min_temp: float, max_temp: float) -> void:
	good_range_min = min_temp
	good_range_max = max_temp
	
func set_temperature(temp: float, text: String = "") -> void:
	temperature = temp
	description = text

func display() -> void:
	var _label: Label = %DEGREES
	var _degrees: float = temperature
	var _suffix: String = ""
	%DESC.set_text(description)
	match convert_to:
		0:
			_degrees = temperature
			_suffix = "K"
		1:
			_degrees = Weather.convert_kelvin_to_celcius_f(temperature)
			_suffix = "°C"
		2:
			@warning_ignore("narrowing_conversion")
			_degrees = Weather.convert_kelvin_to_fahrenheint(temperature)
			_suffix = "°F"
	_label.set_text("%.0f %s" % [_degrees, _suffix])
	if temperature > good_range_max:
		_label.set_modulate(temperature_bad)
	elif temperature < good_range_min:
		_label.set_modulate(temperature_under)
	else:
		_label.set_modulate(temperature_ok)

func _process(_delta: float) -> void:
	display()
