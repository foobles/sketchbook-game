tool
extends Node2D

class_name Hitbox

export(int) var width_radius = 10 setget set_width_radius
export(int) var height_radius = 10 setget set_height_radius

func _process(_delta):
	update()

func set_width_radius(new_width):
	width_radius = new_width 
	update()
	
func set_height_radius(new_height):
	height_radius = new_height 
	update()

func _draw():
	var center = to_local(global_position.floor())
	var v = Vector2(width_radius, height_radius)
	draw_rect(
		Rect2(center-v, 2*v + Vector2(1, 1)),
		Color(0.3, 0.5, 0.9, 0.3)
	)
