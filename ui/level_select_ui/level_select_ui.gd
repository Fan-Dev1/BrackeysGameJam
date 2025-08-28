class_name LevelSelectUi
extends Node

const level_slot_scene = preload("res://ui/level_select_ui/level_slot.tscn")

var slot_button_group := ButtonGroup.new()

@onready var level_mission_preloader: ResourcePreloader = $LevelMissionPreloader
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var car_drive_scroller: CarDriverScroller = %CarDriveScroller

@onready var level_grid_container: GridContainer = %LevelGridContainer
@onready var mission_details: MissionDetailUi = %MissionDetails


func _ready() -> void:
	slot_button_group.allow_unpress = false
	_setup_level_slots()
	var first_level_slot: LevelSlot = level_grid_container.get_child(0)
	first_level_slot.set_pressed.call_deferred(true)
	animation_player.play("enter_scene")
	car_drive_scroller.play_enter_driving()


func _setup_level_slots() -> void:
	for child in level_grid_container.get_children():
		child.queue_free()
	
	for resource_name in level_mission_preloader.get_resource_list():
		var level_mission: LevelMission = level_mission_preloader.get_resource(resource_name)
		if not level_mission is LevelMission:
			push_warning("level_mission_preloader was not a level_mission: " + str(level_mission_preloader))
		
		var level_slot: LevelSlot = level_slot_scene.instantiate()
		level_slot.set_level_mission(level_mission)
		level_slot.level_mission_selected.connect(_on_level_mission_selected)
		level_slot.button_group = slot_button_group
		level_grid_container.add_child(level_slot)


func _on_level_mission_selected(level_mission: LevelMission) -> void:
	mission_details.set_level_mission(level_mission)


func _on_mission_details_mission_started(level_mission: LevelMission) -> void:
	animation_player.play("exit_scene")
	car_drive_scroller.play_exit_driving()
	ResourceLoader.load_threaded_request(level_mission.level_path)
	await animation_player.animation_finished
	var loaded_level := ResourceLoader.load_threaded_get(level_mission.level_path)
	get_tree().change_scene_to_packed(loaded_level)


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
