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
	return [
		{
			name = "flagged_tiles",
			default_value = PoolByteArray()
		}
	]
	
func get_option_visibility(option, options):
	return true 

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
	
	var texture = ImageTexture.new()
	texture.create_from_image(
		image,
		Texture.FLAG_MIPMAPS | Texture.FLAG_REPEAT
	)
	
	var tileset = TileSet.new() 
	var tile_id = 0
	for y in range(height / 16):
		for x in range(width / 16):
			_add_block(collision_map, image, x*16, y*16)
			tileset.create_tile(tile_id)
			tileset.tile_set_texture(tile_id, texture)
			tileset.tile_set_region(tile_id, Rect2(x*16, y*16, 16, 16))
			tileset.tile_set_tile_mode(tile_id, TileSet.SINGLE_TILE)
			tile_id += 1
		
	for flagged_tile_idx in options.flagged_tiles:
		collision_map.data[flagged_tile_idx].angle = 255
		
	err = ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], collision_map)
	if err != OK:
		return err
	
	var tileset_path = "%s_tiles.generated.res" % [source_file.get_basename()]
	err = ResourceSaver.save(tileset_path, tileset)
	if err != OK:
		return err
	gen_files.append(tileset_path)


func _add_block(collision_map, image, block_x, block_y):
	var block = CollisionBlock.new()
	var heights = PoolByteArray() 
	var widths = PoolByteArray()
	var top_right_path_x = 0
	var bottom_left_path_y = 0
	for x in range(16):
		var y = 0
		while y < 16:
			var px = image.get_pixel(block_x + x, block_y + y)
			if px == Color.red:
				top_right_path_x = x 
			if px != Color.black: 
				break  
			y += 1
		heights.append(16 - y) 
			
	for y in range(16):
		var x = 0
		while x < 16:
			var px = image.get_pixel(block_x + x, block_y + y)
			if px == Color.red:
				bottom_left_path_y = y 
			if px != Color.black: 
				break 
			x += 1
		widths.append(16 - x)
	
	var block_width = top_right_path_x - (16 - widths[bottom_left_path_y])
	var block_height = bottom_left_path_y - (16 - heights[top_right_path_x])
	block.widths = widths 
	block.heights = heights
	block.angle = int(round(atan2(block_height, block_width)/(2*PI)*256))
	collision_map.data.append(block)
