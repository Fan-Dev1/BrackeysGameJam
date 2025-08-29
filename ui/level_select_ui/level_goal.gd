class_name LevelGoal
extends Resource

enum Type { MAIN_GOAL, STRETCH_GOAL, HIDDEN_GOAL }

@export var goal_text := ""
@export var goal_reached := false
@export var goal_type := Type.MAIN_GOAL
