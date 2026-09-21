class_name PercentageMeter extends PanelContainer

@export_color_no_alpha var value_ok: Color
@export_color_no_alpha var value_bad: Color

@export var description: String = ""
@export var value: float = 0.0 # Radians
@export var good_range_min: float = 0
@export var good_range_max: float = 1

func set_range(min_temp: float, max_temp: float) -> void:
	good_range_min = min_temp
	good_range_max = max_temp
	
func set_percentage(radians: float, text: String = "") -> void:
	value = radians
	description = text

func display() -> void:
	var _label: Label = %PERCENTAGE
	var _suffix: String = ""
	%DESC.set_text(description)
	_label.set_text("%.0f%%" % (value * 100))
	if value * 100 in range(good_range_min * 100, good_range_max * 100):
		_label.set_modulate(value_ok)
	elif value > good_range_max:
		_label.set_modulate(value_bad)
	elif value < good_range_min:
		_label.set_modulate(value_ok)

func _process(_delta: float) -> void:
	display()
