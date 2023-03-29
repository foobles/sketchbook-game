tool
extends Node2D
class_name YIndexArray

var limit_array: Array = []

func get_limit(test_x):
	if len(limit_array) == 0:
		return -1

	var lo = 0
	var hi = len(limit_array) - 1
	while lo != hi:
		var cur_idx = (lo + hi + 1) >> 1
		var cur_x = limit_array[cur_idx].x
		if test_x < cur_x:
			hi = cur_idx - 1
		else:
			lo = cur_idx
	return limit_array[lo].y


class XSorter:
	static func compare_x(v: Vector2, u: Vector2) -> bool:
		return v.x < u.x


func _update_array():
	limit_array = []
	for child in get_children():
		limit_array.append(child.position)
		
	limit_array.sort_custom(XSorter, "compare_x")

func _init():
	if !is_connected("child_entered_tree", self, "_on_child_entered_tree"):
		connect("child_entered_tree", self, "_on_child_entered_tree")
		
		
func _on_child_entered_tree(child):
	if child is YIndex:
		if !child.is_connected("moved", self, "_on_child_updated"):
			child.connect("moved", self, "_on_child_updated")
			
		if !child.is_connected("tree_exited", self, "_on_child_updated"):
			child.connect("tree_exited", self, "_on_child_updated")
		
	_update_array()
	update()
	
	
func _on_child_updated():
	_update_array()
	update()

func _ready():
	if Engine.editor_hint:
		return
		
	_update_array()
	
	
func _get_configuration_warning():
	for child in get_children():
		if !(child is YIndex):
			return "Please only add YIndex nodes as children in editor. They will all be deleted at runtime."
			
		if (child.get_child_count() > 0):
			return "The enrichment center reminds you that nested children of this node will be ignored."
			
	return ""


func _draw():
	if len(limit_array) <= 1:
		return

	var i = 1
	while i < len(limit_array):
		var pos = limit_array[i-1]
		var width = limit_array[i].x - pos.x
		draw_line(pos, pos + Vector2.RIGHT * width, Color.red, 2, true)
		i += 1
