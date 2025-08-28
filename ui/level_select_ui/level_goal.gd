class_name LevelGoal
extends Resource


@export var goal_text := ""
@export var goal_reached := false

@export_enum("main_goal", "stretch_goal", "hidden_goal") 
var goal_type: int
