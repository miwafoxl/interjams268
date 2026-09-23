extends Node3D

func _ready() -> void:
	await $PLAYER.b_inited
	$PLAYER.add_player_controls()
