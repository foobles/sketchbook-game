tool
extends EditorImportPlugin

enum Presets { DEFAULT }

const CollisionMap = preload("res://resource_types/collision_map.gd")
const CollisionBlock = preload("res://resource_types/collision_block.gd")

func get_importer_name():
	return "sketchbook.collisionmap"
	
func get_visible_name():
	return "Sketchbook Collision Map"
	
func get_recognized_extensions():
	return ["png", "bmp"]
	
func get_save_extension():
	return "res"
	
func get_resource_type():
	return "Resource"
	
func get_preset_count():
	return Presets.size()
	
func get_preset_name(preset):
	match preset:
		Presets.DEFAULT: 
			return "Default"
		_:
			return "[unknown]"

func get_import_options(preset):
	return []

func import(
	source_file, 
	save_path, 
	options, 
	platform_variants, 
	gen_files
):
	var image = Image.new()
	var err = image.load(source_file)
	if err != OK:
		return err
	
	image.lock()
	var width = image.get_width() 
	var height = image.get_height() 
	if width % 16 != 0 || height % 16 != 0:
		return ERR_INVALID_DATA
		
	var collision_map = CollisionMap.new()
	collision_map.data = []
	
	for y in range(height / 16):
		for x in range(width / 16):
			_add_block(collision_map, image, x*16, y*16)
		
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], collision_map)
	

func _add_block(collision_map, image, block_x, block_y):
	var block = CollisionBlock.new()
	var heights = PoolByteArray() 
	var widths = PoolByteArray()
	var leftmost_nonzero_x = 16
	for x in range(16):
		var y = 0
		while y < 16:
			var px = image.get_pixel(block_x + x, block_y + y)
			if px != Color.black: 
				break 
			y += 1
		heights.append(16 - y) 
		if leftmost_nonzero_x == 16 && y != 16:
			leftmost_nonzero_x = x 
			
	for y in range(16):
		var x = 0
		while x < 16:
			var px = image.get_pixel(block_x + x, block_y + y)
			if px != Color.black: 
				break 
			x += 1
		widths.append(16 - x)
	
	var block_width = 15 
	var block_height = heights[15] 
	if leftmost_nonzero_x != 16:
		block_width -= leftmost_nonzero_x
		block_height -= heights[leftmost_nonzero_x]
		
	block.widths = widths 
	block.heights = heights
	block.angle = round(atan2(block_height, block_width)/(2*PI)*256)
	collision_map.data.append(block)
