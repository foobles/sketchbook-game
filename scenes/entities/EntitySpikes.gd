extends "res://scenes/entities/EntitySolid.gd"


func tick_player_interaction(player):
	.tick_player_interaction(player)
	if player.stood_object == self:
		player.force_inflict_damage(self)
