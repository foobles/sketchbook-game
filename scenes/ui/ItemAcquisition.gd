extends NinePatchRect

const TITLE_TEMPLATE = "New %s Acquired!"

onready var title_label = $"%Title"
onready var item_name_label = $"%ItemName"
onready var item_description_label = $"%ItemDescription"
onready var item_image = $"%ItemImage"
onready var ok_selection = $"%OkSelection"

func show_item_info(item):
	set_acquisition_type(item.item_type)
	set_item_name(item.name)
	set_item_description(item.description)
	set_item_image_texture(item.info_card_texture)

func set_item_name(text):
	item_name_label.text = StringUtil.pad_even("\"%s\"" % [text])
	
func set_item_description(text):
	item_description_label.text = text
	
func set_acquisition_type(type_name):
	title_label.text = StringUtil.pad_even(TITLE_TEMPLATE % [type_name]) + '\n'

func set_item_image_texture(texture):
	item_image.texture = texture


func _on_OkSelection_item_selected(_item_index):
	get_tree().current_scene.ui.close_menu()
