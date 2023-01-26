extends CanvasLayer

var ITEM_ACQUISITION = preload("res://scenes/ui/ItemAcquisition.tscn")

var menu = null

onready var viewport = $ViewportContainer/Viewport
onready var material = $ViewportContainer.material

var SHOW_TILES_TIME = 1

var tiles_shown = 0
var tile_show_timer = 0

func _ready():
	var parent_vp_size = get_viewport().size
	viewport.size = parent_vp_size
	var parent_vp_center = parent_vp_size / 2
	material.set_shader_param("center_pixel", [parent_vp_center.x, parent_vp_center.y])


func _physics_process(_delta):
	if tile_show_timer > 0:
		tile_show_timer -= 1
		if tile_show_timer == 0:
			tiles_shown += 1
			material.set_shader_param("tiles_from_center_visible", tiles_shown)
			if tiles_shown < 14:
				tile_show_timer = SHOW_TILES_TIME
			

func open_menu(menu_scene):
	assert(menu == null)
	menu = menu_scene.instance()
	viewport.add_child(menu)
	get_tree().paused = true
	begin_show_tiles_animation()
	
	
func close_menu():
	if menu != null:
		menu.queue_free()
		menu = null
		get_tree().paused = false


func begin_show_tiles_animation():
	tile_show_timer = SHOW_TILES_TIME
	tiles_shown = 0
	material.set_shader_param("tiles_from_center_visible", tiles_shown)
