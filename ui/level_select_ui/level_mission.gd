class_name LevelMission
extends Resource

@export var level_index := 1
@export var level_name := "Level %2d" % level_index
@export_file("*.tscn") var level_path: String
@export var level_preview_texture: Texture
@export var level_music: AudioStream

@export var level_goals: Array[LevelGoal] = []
@export var used_device_count := PackedInt32Array()
@export var unlocked := false
@export var level_completion_time := 120.0


func can_finish_mission() -> bool:
	return main_goals().all(func (level_goal: LevelGoal):
		return level_goal.goal_reached == true)


func main_goals() -> Array[LevelGoal]:
	return level_goals.filter(func (level_goal: LevelGoal): 
		return level_goal.goal_type == LevelGoal.Type.MAIN_GOAL)


func update_goal(index: int, goal_reached: bool) -> void:
	if index >= level_goals.size():
		push_warning("out of bounds: " + str(index))
		return
	var level_goal := level_goals[index]
	if level_goal != null:
		level_goal.goal_reached = goal_reached
	else:
		push_warning("level_goal was null at: " + str(index))
