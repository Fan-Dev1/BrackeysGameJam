class_name CookieStash 
extends Area2D

signal cookie_looted(from: CookieStash)

@export var loot_duration_sec: float

@onready var loot_timer: Timer = $LootTimer
@onready var loot_progress_bar: ProgressBar = %LootProgressBar
@onready var cookie_particles: GPUParticles2D = $CookieParticles


func _ready() -> void:
	loot_progress_bar.visible = false
	cookie_particles.emitting = false


func _process(_delta: float) -> void:
	if is_looting():
		loot_progress_bar.value = loot_timer.wait_time - loot_timer.time_left


func start_looting() -> void:
	loot_timer.start(loot_duration_sec)
	loot_progress_bar.max_value = loot_timer.wait_time
	loot_progress_bar.value = 0.0
	loot_progress_bar.visible = true
	cookie_particles.emitting = true


func stop_looting() -> void:
	loot_timer.stop()
	loot_progress_bar.visible = false
	cookie_particles.emitting = false


func finish_looting() -> void:
	var player: Player = Global.get_player()
	cookie_looted.emit(self)
	player.take_cookie_from(self)
	loot_progress_bar.visible = false
	cookie_particles.emitting = false
	queue_free()


func is_looting() -> bool:
	return not loot_timer.is_stopped()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		start_looting()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		stop_looting()


func _on_loot_timer_timeout() -> void:
	finish_looting()
