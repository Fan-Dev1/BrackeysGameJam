class_name Level 
extends Node2D

@onready var player: Player = $Player
@onready var level_timer: Timer = $LevelTimer
@onready var cookies_label: Label = %CookiesLabel
@onready var time_label: Label = %TimeLabel

@onready var level_complete_panel: PanelContainer = %LevelCompletePanel
@onready var timeout_panel: PanelContainer = %TimeoutPanel

var available_cookie_count := 0
var collected_cookie_count := 0


func _ready() -> void:
	available_cookie_count = get_tree().get_nodes_in_group("cookie_stash").size()
	cookies_label.text = "Cookies: %2d/%2d" % [collected_cookie_count, available_cookie_count]
	timeout_panel.visible = false
	level_complete_panel.visible = false


func _process(delta: float) -> void:
	time_label.text = "Time: %s" % Global.format_as_time(level_timer.time_left)


func _on_exit_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	if player.has_cookie:
		player.drop_of_cookie()
		collected_cookie_count += 1
		cookies_label.text = "Cookies: %2d/%2d" % [collected_cookie_count, available_cookie_count]
	
	if collected_cookie_count >= available_cookie_count:
		on_level_completed()


func on_level_completed():
	get_tree().set_pause.call_deferred(true)
	level_complete_panel.visible = true


func _on_level_timer_timeout() -> void:
	get_tree().set_pause.call_deferred(true)
	timeout_panel.visible = true


func _on_next_level_button_pressed() -> void:
	Global.load_next_level()


func _on_retry_level_button_pressed() -> void:
	Global.retry_level()
