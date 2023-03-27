extends "res://scenes/entities/Entity.gd"

var checked = false

func tick_player_interaction(player):
	if hitbox.collides_with(player.hitbox) && !checked:
		player.respawn_pos = global_position
		checked = true
