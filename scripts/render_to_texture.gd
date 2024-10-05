extends Node3D


func _ready() -> void:
	get_viewport().get_window().size = Vector2i(1024, 1024)
	for i in 100:
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)
	img.save_png("res://russdude.png")
	print("saved image")
