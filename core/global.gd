extends CanvasLayer

signal player_spotted(position: Vector2)

@onready var theme_music_player: AudioStreamPlayer = $ThemeMusicPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	player_spotted.connect(_mark_spotted_player_position)
	play_fade_in()


func play_fade_out():
	animation_player.play("fade_out")
	await animation_player.animation_finished 


func play_fade_in():
	animation_player.play("fade_in")
	await animation_player.animation_finished


func _mark_spotted_player_position(player_position: Vector2) -> void:
	if not OS.is_debug_build():
		return
	var spotted_marker := ColorRect.new()
	spotted_marker.color = Color.DARK_MAGENTA
	spotted_marker.size = Vector2(8.0, 8.0)
	spotted_marker.global_position = player_position
	spotted_marker.z_index = 5
	add_child(spotted_marker)
	await get_tree().create_timer(0.5).timeout
	spotted_marker.queue_free()


func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")


func _on_theme_music_player_finished() -> void:
	theme_music_player.play()
