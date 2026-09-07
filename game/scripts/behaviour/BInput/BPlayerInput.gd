class_name BPlayerInput extends BInput

func condition(_delta: float) -> bool:
	move_vector = Input.get_vector("move_left", "move_right", \
		"move_forwards", "move_backwards")
	aim_vector = Vector2.from_angle(actor.get_angle_to(DisplayServer.mouse_get_position()))
	fire = Input.is_action_pressed("fire")
	alt_fire = Input.is_action_pressed("alt_fire")
	return true
