class_name RestaurantWindows extends Node

@onready var windows: Array = get_children()

func _ready() -> void:
	for i in windows.size():
		var _window: GWindow = windows[i]
		_window.open = bool((Random.value - i) % 2)
