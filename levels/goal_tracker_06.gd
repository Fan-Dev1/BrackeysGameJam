extends Node


var saw_concept := false

@onready var level_06: Level = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



func update_mission_goals() -> void:
	var level_goals := level_06.level_mission.level_goals
	var saw_concept_goal := level_goals[1]
	saw_concept_goal.goal_reached = saw_concept


func _on_focus_game_concept_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		saw_concept = true
