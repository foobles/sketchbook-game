tool
extends Control

const Item = preload("res://scenes/ui/SelectionListItem.tscn")

export(bool) var active = false
export(PoolStringArray) var items = PoolStringArray() setget set_items

signal item_selected(item_index)

var selected_item = 0

func _ready():
	if Engine.editor_hint:
		return
		
	set_items(items)
	if len(items) > 0:
		$SelectionList.get_child(0).selected = true


func _input(event):
	if Engine.editor_hint || !active || len(items) == 0:
		return
		
	if event.is_action_pressed("ui_up"):
		change_selected_item(selected_item - 1)
	elif event.is_action_pressed("ui_down"):
		change_selected_item(selected_item + 1)
	elif event.is_action_pressed("ui_accept"):
		emit_signal("item_selected", selected_item)
	else:
		return
		
	get_tree().set_input_as_handled()
	
	
func change_selected_item(new_selection):
	$SelectionList.get_child(selected_item).selected = false
	selected_item = clamp(new_selection, 0, len(items) - 1)
	$SelectionList.get_child(selected_item).selected = true


func set_items(new_items):
	items = new_items
	
	var item_count = len(items)
	var child_count = $SelectionList.get_child_count()
	for i in range(child_count):
		var c = $SelectionList.get_child(i)
		if i < item_count:
			c.text = items[i]
		else:
			c.queue_free()
	
	for i in range(child_count, item_count):
		var c = Item.instance()
		c.text = items[i]
		$SelectionList.add_child(c)
		
	rect_min_size.y = (2 * item_count + 1) * 8
		
