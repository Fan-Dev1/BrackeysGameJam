class_name LevelSelectUi
extends Node


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var car_drive_scroller: CarDriverScroller = %CarDriveScroller
@onready var mission_details: MissionDetailUi = %MissionDetails
@onready var level_selector: Control = %LevelSelector


func _ready() -> void:
	animation_player.play("enter_scene")
	car_drive_scroller.play_enter_driving()


func _on_level_selector_level_selected(level_mission: LevelMission) -> void:
	mission_details.set_level_mission(level_mission)


func _on_mission_details_mission_started(level_mission: LevelMission) -> void:
	animation_player.play("exit_scene")
	#car_drive_scroller.play_exit_driving() # crashes web export
	print("_on_mission_details_mission_started load_threaded_request")
	ResourceLoader.load_threaded_request(level_mission.level_path)
	#await animation_player.animation_finished
	await Global.play_fade_out()
	print("_on_mission_details_mission_started load_threaded_get")
	var loaded_level := ResourceLoader.load_threaded_get(level_mission.level_path)
	print("_on_mission_details_mission_started change_scene_to_packed")
	get_tree().change_scene_to_packed(loaded_level)
	#get_tree().change_scene_to_file(level_mission.level_path)
	Global.play_fade_in()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
