class_name MissionDetailUi
extends Container

signal mission_started(level_mission: LevelMission)
signal mission_finished(level_mission: LevelMission)

const GOAL_CHECK_BOX: PackedScene = preload("res://ui/level_select_ui/goal_check_box.tscn")

@export var level_mission: LevelMission : set = set_level_mission
@export var in_mission := false

@onready var title_label: Label = %TitleLabel
@onready var main_goal_container: VBoxContainer = %MainGoalContainer
@onready var stretch_goal_container: VBoxContainer = %StretchGoalContainer
@onready var mission_button: Button = %MissionButton


func _ready() -> void:
	_update_ui()


func _update_ui() -> void:
	if level_mission == null:
		return
	if in_mission:
		mission_button.text = "Finish Mission"
		mission_button.disabled = not level_mission.can_finish_mission()
	else:
		mission_button.text = "Start Mission"
		mission_button.disabled = not level_mission.unlocked
	
	title_label.text = level_mission.level_name
	for old_goal in main_goal_container.get_children():
		main_goal_container.remove_child(old_goal)
		old_goal.queue_free()
	for old_goal in stretch_goal_container.get_children():
		stretch_goal_container.remove_child(old_goal)
		old_goal.queue_free()
	
	for level_goal: LevelGoal in level_mission.level_goals:
		var goal_checkbox: CheckBox = GOAL_CHECK_BOX.instantiate()
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
	if is_node_ready():
		_update_ui()


func _on_mission_button_pressed():
	if in_mission:
		mission_finished.emit(level_mission)
	else:
		mission_started.emit(level_mission)
