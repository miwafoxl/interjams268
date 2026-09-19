class_name Random extends Node

static var current_seed: int = floor(Time.get_unix_time_from_system())

func _ready() -> void:
	seed(current_seed)
