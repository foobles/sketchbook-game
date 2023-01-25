extends Resource

export(String, "Item", "Ability") var item_type
export(String) var name
export(String, MULTILINE) var description
export(Texture) var info_card_texture

func open_acquisition_menu(tree: SceneTree):
	var ui = tree.current_scene.ui
	ui.open_menu(ui.ITEM_ACQUISITION)
	ui.menu.show_item_info(self)


func on_acquisition(player):
	open_acquisition_menu(player.get_tree())
