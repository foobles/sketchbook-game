extends Node

onready var ui = $UI

func open_item_menu():
	ui.open_menu(ui.ITEM_ACQUISITION)
	ui.menu.set_item_name("test")
	ui.menu.set_acquisition_type("item")
	ui.menu.set_item_description("hello world")

func _input(event):
	if event.is_action_pressed("ui_left"):
		if ui.menu == null:
			open_item_menu()
	elif event.is_action_pressed("ui_right"):
		ui.close_menu()
	else:
		return
		
	get_tree().set_input_as_handled()
