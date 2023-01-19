extends NinePatchRect

const TITLE_TEMPLATE = "New %s Acquired!"

onready var title_label = $"%Title"
onready var item_name_label = $"%ItemName"
onready var item_description_label = $"%ItemDescription"
onready var item_image = $"%ItemImage"
onready var ok_selection = $"%OkSelection"

func set_item_name(text):
	item_name_label.text = StringUtil.pad_even("\"%s\"" % [text])
	
func set_item_description(text):
	item_description_label.text = text
	
func set_acquisition_type(type_name):
	title_label.text = StringUtil.pad_even(TITLE_TEMPLATE % [type_name]) + '\n'

func set_item_image_texture(texture):
	item_image.texture = texture
