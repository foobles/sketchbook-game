tool
extends Node2D
class_name YIndex

signal moved

func _init():
	set_notify_local_transform(true)
	

func _notification(what):
	if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
		emit_signal("moved")
