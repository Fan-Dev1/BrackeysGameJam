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
