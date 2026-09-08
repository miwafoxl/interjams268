extends Node3D

func _ready() -> void:
	$ENTITY.add_player_controls()
	$"Test interaction".behaviour_event.connect(test)

func test(event: String) -> void:
	print("WAOOOOOOOO %s" % event)
