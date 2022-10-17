tool
extends "res://scenes/entities/Entity.gd"

const THICKNESS = 8
enum Orientation { VERTICAL, HORIZONTAL }

export(bool) var require_upside_down = false
export(Orientation) var orientation = Orientation.VERTICAL setget set_orientation
export(int) var length = 32 setget set_length

export(int, 0, 1) var positive_direction_layer 
export(int, 0, 1) var negative_direction_layer

func _recompute_hb():
	match orientation:
		Orientation.VERTICAL:
			$Hitbox.radius = Vector2(THICKNESS, length) 
		Orientation.HORIZONTAL:
			$Hitbox.radius = Vector2(length, THICKNESS) 

func set_orientation(new_orientation):
	orientation = new_orientation
	_recompute_hb() 
	
func set_length(new_length):
	length = new_length
	_recompute_hb()
	
	
func tick_player_interaction(player):
	if collides_with_entity(player):
		var dir 
		match orientation:
			Orientation.VERTICAL:
				dir = player.velocity.x 
			Orientation.HORIZONTAL:
				dir = player.velocity.y 
		
		if require_upside_down && player.pose.direction != 2:
			return 
		if dir < 0:
			player.pose.set_layer(negative_direction_layer)
		elif dir > 0:
			player.pose.set_layer(positive_direction_layer)
