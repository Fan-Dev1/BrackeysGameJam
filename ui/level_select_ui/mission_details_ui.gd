class_name MissionDetailUi
extends Container

signal mission_started(level_mission: LevelMission)

@export var level_mission: LevelMission : set = set_level_mission

@onready var title_label: Label = %TitleLabel
@onready var main_goal_container: VBoxContainer = %MainGoalContainer
@onready var stretch_goal_container: VBoxContainer = %StretchGoalContainer
@onready var device_grid_container: GridContainer = %DeviceGridContainer
@onready var start_mission_button: Button = %StartMissionButton


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if level_mission == null:
		return
	title_label.text = level_mission.level_name
	start_mission_button.disabled = not level_mission.unlocked
	
	for old_goal in main_goal_container.get_children():
		old_goal.queue_free()
	for old_goal in stretch_goal_container.get_children():
		old_goal.queue_free()
	
	var goal_checkbox: CheckBox = main_goal_container.get_child(0)
	for level_goal: LevelGoal in level_mission.level_goals:
		goal_checkbox = goal_checkbox.duplicate()
		goal_checkbox.text = level_goal.goal_text
		goal_checkbox.button_pressed = level_goal.goal_reached
		var is_hidden_goal := level_goal.goal_type == 2
		goal_checkbox.visible = level_goal.goal_reached or not is_hidden_goal
		if level_goal.goal_type == 0:
			main_goal_container.add_child(goal_checkbox)
		else:
			stretch_goal_container.add_child(goal_checkbox)


func set_level_mission(_level_mission: LevelMission) -> void:
	level_mission = _level_mission
	_update_ui()


func _on_start_mission_button_pressed() -> void:
	mission_started.emit(level_mission)
