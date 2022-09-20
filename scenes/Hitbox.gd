tool
extends Node2D

class_name Hitbox

export(Vector2) var radius = Vector2(10, 10) setget set_radius

func _process(_delta):
	update()
	
func set_radius(new_radius):
	radius = new_radius 
	update()

func _draw():
	var center = to_local(global_position.floor())
	draw_rect(
		Rect2(center-radius, 2*radius + Vector2(1, 1)),
		Color(0.3, 0.5, 0.9, 0.3)
	)
