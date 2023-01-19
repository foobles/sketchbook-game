tool
extends Control

const Item = preload("res://scenes/ui/SelectionListItem.tscn")

export(bool) var active = false
export(PoolStringArray) var items = PoolStringArray() setget set_items

var selected_item = 0

func _ready():
	if Engine.editor_hint:
		return
		
	set_items(items)
	if len(items) > 0:
		$SelectionList.get_child(0).selected = true


func _input(event):
	var item_count = len(items)
	if Engine.editor_hint || !active || item_count == 0:
		return
		
	var new_selection = selected_item
	if event.is_action_pressed("ui_up"):
		new_selection -= 1
	elif event.is_action_pressed("ui_down"):
		new_selection += 1
	else:
		return
		
	$SelectionList.get_child(selected_item).selected = false
	selected_item = clamp(new_selection, 0, item_count - 1)
	$SelectionList.get_child(selected_item).selected = true
	get_tree().set_input_as_handled()
	

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
		
