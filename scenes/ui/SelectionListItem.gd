tool
extends NinePatchRect

const UNSELECTED_NINEPATCH_ORIGIN = Vector2(36, 4)
const SELECTED_NINEPATCH_ORIGIN = Vector2(52, 4)

const UNSELECTED_TEXT_COLOR = Color8(0xff, 0xff, 0xff)
const SELECTED_TEXT_COLOR = Color8(0x00, 0x84, 0xff)


export(bool) var selected = false setget set_selected
export(String) var text = "" setget set_text

func _ready():
	rect_min_size.y = 16

func set_selected(new_selected):
	selected = new_selected
	if selected:
		region_rect.position = SELECTED_NINEPATCH_ORIGIN
		$Label.add_color_override("font_color", SELECTED_TEXT_COLOR)
	else:
		region_rect.position = UNSELECTED_NINEPATCH_ORIGIN
		$Label.add_color_override("font_color", UNSELECTED_TEXT_COLOR)

func set_text(new_text):
	text = new_text
	$Label.text = StringUtil.pad_even(text)
