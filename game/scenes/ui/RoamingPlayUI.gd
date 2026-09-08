class_name RoamPlayUI extends Control

@export var player: GameObject = null

static var can_interact: bool = false

func _process(_delta: float) -> void:
	if can_interact and not %"HBOX INTERACT".visible:
		%"HBOX INTERACT".set_visible(true)
	elif not can_interact and %"HBOX INTERACT".visible:
		%"HBOX INTERACT".set_visible(false)
