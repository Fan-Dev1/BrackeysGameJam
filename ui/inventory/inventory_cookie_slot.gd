class_name InventoryCookieSlot
extends VBoxContainer

@export var cookie_id := 0 : set = set_cookie_id

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	label.text = "Cookie %2d" % cookie_id
	var rng := RandomNumberGenerator.new()
	rng.seed = cookie_id
	texture_rect.self_modulate = Color(rng.randf(), rng.randf(), rng.randf())


func set_cookie_id(_cookie_id: int) -> void:
	cookie_id = _cookie_id
	queue_redraw()
