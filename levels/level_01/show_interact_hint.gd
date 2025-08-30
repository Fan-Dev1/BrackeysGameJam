extends Label


@export var door: Door

var highlighted := false
var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.TRANSPARENT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if highlighted == door.is_highlighted():
		return
	highlighted = door.is_highlighted()
	
	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	if highlighted:
		tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	else:
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
