extends Node2D

@export_file("*.png") var cover_save_file := "res://ui/itch/itch_cover_scene.png"

@onready var camera_2d: Camera2D = %Camera2D
@onready var cover_rect: ReferenceRect = %CoverReferenceRect


func _ready():
	take_scene_screen_shot.call_deferred()


func take_scene_screen_shot() -> void:
	await get_tree().process_frame
	camera_2d.global_position = cover_rect.global_position
	await get_tree().create_timer(1.1).timeout
	
	var width := cover_rect.size.x 
	var height := cover_rect.size.y
	var scaled_width := width * cover_rect.scale.x
	var scaled_height := height * cover_rect.scale.y
	
	var img: Image = get_viewport().get_texture().get_image()
	img.crop(scaled_width, scaled_height)
	img.resize(width, height, Image.INTERPOLATE_NEAREST)
	
	var err := img.save_png(cover_save_file)
	if err == OK:
		print("Screenshot saved to: %s" % cover_save_file)
	else:
		push_error("Failed to save screenshot: %s" % cover_save_file)
	
	await get_tree().process_frame
	get_tree().quit()
