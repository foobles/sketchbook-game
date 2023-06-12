extends "res://scenes/entities/EntitySolid.gd"

func handle_horizontal_collision(player, x_distance):
	if player.is_grounded && player.is_rolling && abs(player.ground_speed) > 4:
		player.position.x -= x_distance
		player.ground_speed -= sign(player.ground_speed)
		queue_free()
	else:
		.handle_horizontal_collision(player, x_distance)
