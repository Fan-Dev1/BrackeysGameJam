class_name GamePausedUI
extends CanvasLayer

const LEVEL_SELECT_UI := "res://ui/level_select_ui/level_select_ui.tscn"

@onready var continue_button = %ContinueButton
@onready var restart_mission_button = %RestartMissionButton
@onready var abort_mission_button = %AbortMissionButton
@onready var settings_button = %SettingsButton
@onready var quit_button = %QuitButton


func _ready():
	pass


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		get_tree().paused = visible


func _on_continue_button_pressed():
	visible = false
	get_tree().paused = false


func _on_restart_mission_button_pressed():
	await Global.play_fade_out()
	get_tree().paused = false
	get_tree().reload_current_scene()
	Global.play_fade_in()


func _on_abort_mission_button_pressed():
	ResourceLoader.load_threaded_request(LEVEL_SELECT_UI)
	await Global.play_fade_out()
	var loaded_level := ResourceLoader.load_threaded_get(LEVEL_SELECT_UI)
	get_tree().paused = false
	get_tree().change_scene_to_packed(loaded_level)
	Global.play_fade_in()


func _on_settings_button_pressed():
	visible = false
	get_tree().paused = false
	# TODO _on_settings_button_pressed


func _on_quit_button_pressed():
	get_tree().quit()
