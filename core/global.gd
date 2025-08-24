extends Node

var levels: Array[String] = [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
]
var current_level_index := 0


func load_next_level():
	current_level_index = clampi(current_level_index + 1, 0, levels.size() - 1)
	var next_level_path: String = levels[current_level_index]
	get_tree().change_scene_to_file(next_level_path)
	get_tree().set_pause(false)


func retry_level():
	var next_level_path: String = levels[current_level_index]
	get_tree().change_scene_to_file(next_level_path)
	get_tree().set_pause(false)


static func format_as_time(total_seconds: float) -> String:
	var minutes := floori(int(total_seconds) / 60.0)
	var seconds := int(total_seconds) % 60
	var milliseconds := int((total_seconds - int(total_seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
