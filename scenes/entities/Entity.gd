extends Node2D

onready var sprite = $Sprite
onready var hitbox = $Hitbox

var map_info = load("res://singletons/tile_map_info.tres")

func collides_with_entity(other):
	return hitbox.collides_with(other.hitbox)


func tick():
	pass

	
func tick_player_interaction(_player):
	pass
