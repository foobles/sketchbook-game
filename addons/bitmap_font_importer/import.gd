tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func get_importer_name():
	return "sketchbook.bitmapfont"


func get_visible_name():
	return "Sketchbook Bitmap Font"


func get_recognized_extensions():
	return ["bmp", "png"]


func get_save_extension():
	return "res"

	
func get_resource_type():
	return "BitmapFont"


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

	var texture = ImageTexture.new()
	texture.create_from_image(
		image,
		Texture.FLAG_REPEAT | Texture.FLAG_MIPMAPS
	)
	
	var font = BitmapFont.new()
	font.add_texture(texture)
	font.height = 8
	
	var size = Vector2(8, 8)
	for i in range(128):
		var pos = 8 * Vector2(i % 16, i / 16)
		font.add_char(i, 0, Rect2(pos, size))
	
	var full_save_path = "%s.%s" % [save_path, get_save_extension()]
	err = ResourceSaver.save(full_save_path, font)
	if err != OK:
		print("err saving: %s" % [err])
		return err
	
