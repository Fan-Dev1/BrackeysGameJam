class_name ThiefCar
extends CharacterBody2D

signal car_entered
signal car_exited
signal cookie_dropped

enum CarFrame { 
	NORMAL=0, CABIN_OUTLINE=1, CARGO_BED_OUTLINE=2,
}
const COOKIE_TEXTURE: Texture2D = preload("res://PlaceholderCharacter/PlaceholderCookie.png")

var player_inside := false

@onready var car_sprite_2d: Sprite2D = %CarSprite2D
@onready var head_lights: PointLight2D = %HeadLights
@onready var tail_lights: PointLight2D = %TailLights
@onready var interaction_area_2d = %InteractionArea2D
@onready var cookie_drop_rect: ReferenceRect = %CookieDropRect


func _ready() -> void:
	car_sprite_2d.frame = CarFrame.NORMAL


func _physics_process(delta):
	var player :=  _find_overlapping_player()
	if player == null:
		car_sprite_2d.frame = CarFrame.NORMAL
	else:
		_update_interaction_outline(player)


func _update_interaction_outline(player: Player) -> void:
	var direction_player := self.global_position.direction_to(player.global_position)
	var on_right_side := direction_player.dot(Vector2.RIGHT) > 0.0
	if on_right_side:
		car_sprite_2d.frame = CarFrame.CABIN_OUTLINE
	else:
		car_sprite_2d.frame = CarFrame.CARGO_BED_OUTLINE


func _find_overlapping_player() -> Player:
	for body in interaction_area_2d.get_overlapping_bodies():
		if body is Player:
			return body
	return null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_handle_interact_input()


func _handle_interact_input() -> void:
	if player_inside:
		player_inside = false
		car_exited.emit()
	elif car_sprite_2d.frame == CarFrame.CABIN_OUTLINE:
		player_inside = true
		car_entered.emit()
	elif car_sprite_2d.frame == CarFrame.CARGO_BED_OUTLINE:
		cookie_dropped.emit()
		_animated_cookie_drop()


func _animated_cookie_drop() -> void:
	for i in range(randi_range(5, 12)):
		var delay := randf_range(0.05, 0.2)
		await get_tree().create_timer(delay).timeout
		_animated_dropped_cookie()
		if cookie_drop_rect.get_child_count() > 30:
			cookie_drop_rect.get_child(0).queue_free()


func _animated_dropped_cookie() -> void:
	var cookie_sprite := Sprite2D.new()
	var scale_factor := Vector2(0.1, 0.1)
	var texture_size := COOKIE_TEXTURE.get_size() * scale_factor
	cookie_sprite.texture = COOKIE_TEXTURE
	cookie_sprite.scale = scale_factor / 2.0
	cookie_sprite.rotation = randf()
	
	cookie_sprite.position = texture_size / 4.0
	var offset_x := randf_range(0.0, 
				cookie_drop_rect.size.x - texture_size.x / 2.0)
	cookie_sprite.position.x += offset_x
	cookie_drop_rect.add_child(cookie_sprite)
	
	var end_height := cookie_drop_rect.size.y
	end_height -= randf_range(0.0, 42.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(cookie_sprite, "scale", scale_factor, 0.075)
	tween.tween_property(cookie_sprite, "position:y", end_height, 0.5)
