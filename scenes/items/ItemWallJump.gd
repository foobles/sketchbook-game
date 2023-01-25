extends "res://resource_types/item.gd"

func on_acquisition(player):
	.on_acquisition(player)
	player.wall_jump_enabled = true
