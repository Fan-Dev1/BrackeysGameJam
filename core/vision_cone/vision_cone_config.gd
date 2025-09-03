@tool
class_name VisionConeConfig
extends Resource

@export var color := Color.WHITE : set = set_color
@export var radius := 256.0 : set = set_radius
@export_range(0.0, 360.0, 0.1, "radians_as_degrees") 
var fov := PI / 4.0 : set = set_fov


func new_cone_area_polygon(circle_points := 16) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()
	var fov_step := fov / circle_points
	var current_angle := -fov_step * (circle_points / 2.0)
	
	new_polygon.append(Vector2(0.0, 0.0))
	for i in range(circle_points + 1):
		new_polygon.append(Vector2.from_angle(current_angle) * radius)
		current_angle += fov_step
	new_polygon.append(Vector2(0.0, 0.0))
	return new_polygon


func new_cone_light_texture() -> Image:
	var image_size := radius * 2.0
	var img := Image.create_empty(image_size, image_size, false, Image.FORMAT_RGBA8)
	
	var center := Vector2(image_size, image_size) / 2.0
	for y in range(image_size):
		for x in range(image_size):
			var pos := Vector2(x, y)
			var dir := pos - center
			var dist := dir.length()
			if is_zero_approx(dist):
				continue
			var dir_angle := absf(atan2(dir.y, dir.x))
			var angle_diff := absf(dir_angle - fov / 2)
			
			if dir_angle <= fov / 2.0 and dist <= image_size / 2.0:
				var color := Color.WHITE
				img.set_pixel(x, y, color)
			else:
				img.set_pixel(x, y, Color.TRANSPARENT)
	return img


func set_radius(_radius: float) -> void:
	if not is_equal_approx(radius, _radius):
		radius = _radius
		emit_changed()


func set_fov(_fov: float) -> void:
	if not is_equal_approx(fov, _fov):
		fov = _fov
		emit_changed()


func set_color(_color: Color) -> void:
	if not color == _color:
		color = _color
		emit_changed()
