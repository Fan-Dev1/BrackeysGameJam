extends Node


var total_door_count := 0
var opened_doors := {}
var check_timer

@onready var level_04: Level = $".."
@onready var doors: Node2D = %Doors


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var doors_in_level := doors.get_children().filter(is_door)
	total_door_count = doors_in_level.size()
	
	for door: Door in doors_in_level:
		door.door_state_changed.connect(_on_door_state_changed.bind(door))


func is_door(node: Node):
	var check: bool = node is Door
	return check


func _on_door_state_changed(state: Door.State, door: Door) -> void:
	if state == Door.State.OPEN:
		opened_doors.set(door, true)


func update_mission_goals() -> void:
	var level_goals := level_04.level_mission.level_goals
	var open_all_doors_goal := level_goals[1]
	open_all_doors_goal.goal_reached = opened_doors.size() >= total_door_count
