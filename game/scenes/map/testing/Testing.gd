extends Node3D

func _ready() -> void:
	$PLAYER.add_player_controls()
	$"INTER TEST".behaviour_event.connect(test)

func test(event: String) -> void:
	match event:
		"test":
			$PLAYER.give_item("fishgame:trouble")
