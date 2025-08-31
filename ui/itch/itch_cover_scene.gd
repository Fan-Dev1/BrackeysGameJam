extends Node2D


func _ready():
	take_scene_screen_shot.call_deferred()


func take_scene_screen_shot() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(1.1).timeout
	
	var img: Image = get_viewport().get_texture().get_image()
	var path := "res://ui/itch/itch_cover_scene.png"
	var err := img.save_png(path)
	if err == OK:
		print("Screenshot saved to: %s" % path)
	else:
		push_error("Failed to save screenshot: %s" % path)
	
	await get_tree().process_frame
	get_tree().quit()
