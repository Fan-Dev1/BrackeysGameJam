extends Node2D


@export var cookie_stash: CookieStash

@onready var cookie_pointer_sprite: PointerSprite = $CookiePointerSprite
@onready var visible_area_2d: Area2D = $VisibleArea2D

@onready var car_pointer_sprite: PointerSprite = $CarPointerSprite
@onready var cargo_bed_pointer_sprite: PointerSprite = $CargoBedPointerSprite
@onready var camera_2d: Camera2D = $Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_area_2d.body_entered.connect(_on_body_entered)
	visible_area_2d.body_exited.connect(_on_body_exited)
	cookie_stash.cookie_looted.connect(_on_cookie_looted)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		cookie_pointer_sprite.start_pointing()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		cookie_pointer_sprite.stop_pointing()


func _on_cookie_looted(from: CookieStash) -> void:
	cookie_pointer_sprite.queue_free()
	visible_area_2d.queue_free()
	visible_area_2d.body_entered.disconnect(_on_body_entered)
	visible_area_2d.body_exited.disconnect(_on_body_exited)
	
	var thief_car: ThiefCar = get_tree().get_first_node_in_group("thief_car")
	thief_car.cookie_dropped.connect(_on_cookie_dropped, CONNECT_ONE_SHOT)
	thief_car.car_entered.connect(_on_car_entered, CONNECT_ONE_SHOT)
	
	var player: Player = Global.get_player()
	player.set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	camera_2d.enabled = true
	camera_2d.make_current()
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera_2d, "global_position", thief_car.global_position, 0.33)
	tween.tween_callback(cargo_bed_pointer_sprite.start_pointing)
	tween.tween_interval(1.0)
	tween.tween_property(camera_2d, "position", Vector2.ZERO, 0.33)
	tween.tween_callback(func ():
		player.set_process_mode.call_deferred(Node.PROCESS_MODE_INHERIT)
		camera_2d.enabled = false)


func _on_cookie_dropped() -> void:
	cargo_bed_pointer_sprite.stop_pointing()
	cargo_bed_pointer_sprite.queue_free()
	car_pointer_sprite.start_pointing()


func _on_car_entered() -> void:
	car_pointer_sprite.stop_pointing()
	car_pointer_sprite.queue_free()
