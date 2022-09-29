tool
extends Node2D

class_name Hitbox

export(Vector2) var radius = Vector2(10, 10) setget set_radius

func _process(_delta):
	update()

func set_radius(new_radius):
	radius = new_radius
	update()


func collides_with(other):
	var combined_radius = radius + other.radius
	var diff = global_position.floor() - (other.global_position.floor() - combined_radius)
	var combined_diameter = 2*combined_radius
	return (
		diff.x >= 0
		&& diff.x <= combined_diameter.x
		&& diff.y >= 0
		&& diff.y <= combined_diameter.y
	)


func _draw():
	var center = to_local(global_position.floor())
	draw_rect(
		Rect2(center-radius, 2*radius + Vector2(1, 1)),
		Color(0.3, 0.5, 0.9, 0.3)
	)
