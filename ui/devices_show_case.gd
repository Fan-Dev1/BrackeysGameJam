extends Node2D

@export_dir var save_dir: String

@onready var camera_2d: Camera2D = %Camera2D
@onready var device_scene_container: Container = %DeviceSceneContainer
@onready var sub_viewport: SubViewport = %SubViewport


func _ready() -> void:
	await get_tree().process_frame
	device_scene_container.reparent.call_deferred(sub_viewport)
	await get_tree().process_frame
	take_screen_shots.call_deferred()


func take_screen_shots() -> void:
	for i in range(device_scene_container.get_child_count()):
		await take_screen_shot(i)
	get_tree().quit()


func take_screen_shot(index: int) -> void:
	var device_scene_rect := device_scene_container.get_child(index)
	if device_scene_rect.get_child_count() == 0:
		return
	
	var reference_rect := device_scene_rect.get_child(0) as ReferenceRect
	var viewport_size := sub_viewport.get_visible_rect().size
	var zoom_x := viewport_size.x / reference_rect.size.x
	var zoom_y := viewport_size.y / reference_rect.size.y
	var zoom_factor = minf(zoom_x, zoom_y)
	camera_2d.zoom = Vector2(zoom_factor, zoom_factor)
	camera_2d.global_position = reference_rect.global_position
	camera_2d.global_position += reference_rect.size / 2.0
	await get_tree().process_frame
	
	var img_name := device_scene_rect.name
	var img: Image = sub_viewport.get_texture().get_image()
	# Save screenshot as PNG
	var path := save_dir + "/%s.png" % img_name
	var err := img.save_png(path)
	if err == OK:
		print("Screenshot saved to: %s" % path)
	else:
		push_error("Failed to save screenshot: %s" % path)
