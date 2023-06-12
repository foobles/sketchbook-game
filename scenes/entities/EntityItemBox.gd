tool
extends "res://scenes/entities/EntitySolidBreakable.gd"

export(Resource) var contents
export(int, "Right", "Left") var facing_direction setget set_facing_direction

const GIVE_ITEM_TIME = 30
var give_item_timer = -1

func tick_player_interaction(player):
	if is_expiring():
		if give_item_timer > 0:
			give_item_timer -= 1
		else:
			contents.on_acquisition(player)
			queue_free()
	else:
		.tick_player_interaction(player)


func on_destroyed(player):
	hide()
	var explosion = EntityParticleExplosion.instance()
	explosion.global_position = global_position
	map_info.objects.add_child(explosion)
	give_item_timer = GIVE_ITEM_TIME

func is_expiring():
	return give_item_timer >= 0


func set_facing_direction(new_facing_direction):
	facing_direction = new_facing_direction
	$Sprite.frame = new_facing_direction
	$Sprite.offset.x = new_facing_direction
	
