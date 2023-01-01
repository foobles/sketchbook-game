extends "res://scenes/entities/Entity.gd"

export var animation_frames = 1
export var ticks_per_frame = 0

onready var ticks = ticks_per_frame

func tick():
	if ticks > 0:
		ticks -= 1
	elif sprite.frame + 1 < animation_frames:
		sprite.frame += 1
		ticks = ticks_per_frame
	else:
		queue_free()
