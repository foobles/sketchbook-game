extends CanvasLayer

var ITEM_ACQUISITION = preload("res://scenes/ui/ItemAcquisition.tscn")

var menu = null

onready var viewport = $ViewportContainer/Viewport
onready var material = $ViewportContainer.material

const TILE_ANIMATION_DELAY = 1

var tile_max

enum AnimationMode {
	OPENING, CLOSING
}

var mode
var tiles_shown = 0
var tile_show_timer = 0

func _ready():
	var parent_vp_size = get_viewport().size
	viewport.size = parent_vp_size
	tile_max = int(max(parent_vp_size.x / 16, parent_vp_size.y / 16))
	var parent_vp_center = parent_vp_size / 2
	material.set_shader_param("center_pixel", [parent_vp_center.x, parent_vp_center.y])


func _physics_process(_delta):
	if tile_show_timer > 0:
		tile_show_timer -= 1
		if tile_show_timer == 0:
			match mode:
				AnimationMode.OPENING:
					tiles_shown += 1
					if tiles_shown < tile_max:
						tile_show_timer = TILE_ANIMATION_DELAY
					else:
						open_menu_finished()
				
				AnimationMode.CLOSING:
					tiles_shown -= 1
					if tiles_shown > 0:
						tile_show_timer = TILE_ANIMATION_DELAY
					else:
						close_menu_finished()
						
			material.set_shader_param("tiles_from_center_visible", tiles_shown)
			

func open_menu(menu_scene):
	assert(menu == null)
	menu = menu_scene.instance()
	viewport.add_child(menu)
	get_tree().paused = true
	begin_show_tiles_animation()
	
	
func close_menu():
	if menu != null:
		begin_hide_tiles_animation()


func begin_show_tiles_animation():
	mode = AnimationMode.OPENING
	tile_show_timer = TILE_ANIMATION_DELAY
	tiles_shown = 0
	material.set_shader_param("tiles_from_center_visible", tiles_shown)


func begin_hide_tiles_animation():
	mode = AnimationMode.CLOSING
	tile_show_timer = TILE_ANIMATION_DELAY
	tiles_shown = material.get_shader_param("tiles_from_center_visible")


func open_menu_finished():
	pass
	
func close_menu_finished():
	assert(menu != null)
	menu.queue_free()
	menu = null
	get_tree().paused = false
