extends "res://scenes/entities/Entity.gd"

func tick_player_interaction(player):
	if hitbox.collides_with(player.hitbox):
		if player.is_rolling:
			if !player.is_grounded:
				if player.position.y < position.y && player.velocity.y > 0:
					player.velocity.y *= -1
				else:
					player.velocity.y -= sign(player.velocity.y)
			on_destroyed(player)
			queue_free()
		else:
			player.inflict_damage(self)


func on_destroyed(_player):
	pass
