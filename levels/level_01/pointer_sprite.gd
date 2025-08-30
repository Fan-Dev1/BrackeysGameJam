class_name PointerSprite
extends Sprite2D


var pointing_tween: Tween
var fade_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_pointing_tween()
	self_modulate = Color.TRANSPARENT


func _setup_pointing_tween() -> void:
	pointing_tween = create_tween()
	pointing_tween.set_loops()
	pointing_tween.set_ease(Tween.EASE_IN_OUT)
	pointing_tween.set_trans(Tween.TRANS_BOUNCE)
	
	var start_position :=  position
	var direction := Vector2.from_angle(global_rotation)
	var end_position :=  start_position + direction * 24.0
	pointing_tween.tween_property(self, "position", end_position, 0.2)
	pointing_tween.chain().tween_property(self, "position", start_position, 0.2)
	pointing_tween.pause()


func start_pointing() -> void:
	fade_in()
	pointing_tween.play()


func stop_pointing() -> void:
	fade_out()
	fade_tween.tween_callback(pointing_tween.pause)


func fade_in() -> void:
	if fade_tween != null:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(self, "self_modulate", Color.WHITE, 0.2)


func fade_out() -> void:
	if fade_tween != null:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 0.2)
