class_name Random extends Node

static var current_seed: int = floor(Time.get_unix_time_from_system())
static var value: int = 0

func _init() -> void:
	seed(current_seed)
	value = randi_range(999_999, 2_147_483_647)
	print(value)
