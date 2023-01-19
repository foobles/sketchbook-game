extends CanvasLayer

var ITEM_ACQUISITION = preload("res://scenes/ui/ItemAcquisition.tscn")

var menu = null

func open_menu(menu_scene):
	assert(menu == null)
	menu = menu_scene.instance()
	add_child(menu)
	get_tree().paused = true
	
	
func close_menu():
	if menu != null:
		menu.queue_free()
		menu = null
		get_tree().paused = false
