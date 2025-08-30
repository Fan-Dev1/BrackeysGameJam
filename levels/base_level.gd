class_name Level 
extends Node2D

const LEVEL_SELECT_UI := "res://ui/level_select_ui/level_select_ui.tscn"

@export var level_mission: LevelMission
@export var masked_by_player_vision_material: Material
@export var skip_drive_animation := false

var available_cookie_count := 0
var collected_cookie_count := 0

@onready var goal_tracker: Node = $GoalTracker
@onready var player: Player = %Player
@onready var camera_2d: Camera2D = %Camera2D
@onready var car_drive_camera_2d: Camera2D = %CarDriveCamera2D
@onready var level_timer: Timer = $LevelTimer
@onready var car_drive_scroller: CarDriverScroller = %CarDriveScroller

@onready var cookies_label: Label = %CookiesLabel
@onready var time_label: Label = %TimeLabel

@onready var timeout_panel: PanelContainer = %TimeoutPanel
@onready var cookie_loot_panel: CookieLootPanel = %CookieLootPanel
@onready var inventory_panel: InventoryPanel = %InventoryPanel
@onready var mission_details: MissionDetailUi = %MissionDetails
@onready var game_paused_ui: GamePausedUI = %GamePausedUI


func _ready() -> void:
	mission_details.set_level_mission(level_mission)
	mission_details.visible = true
	timeout_panel.visible = false
	cookie_loot_panel.visible = false
	inventory_panel.visible = false
	game_paused_ui.visible = false
	_setup_cookie_stashes()
	_setup_masked_by_player_nodes()
	if OS.is_debug_build() and skip_drive_animation:
		car_drive_scroller.stop_scrolling()
		var thief_car := car_drive_scroller.thief_car
		thief_car.set_process_unhandled_input(false)
		mission_details.visible = false
		player.set_process_mode.call_deferred(Node.PROCESS_MODE_INHERIT)
		player.visible = true
		thief_car.set_process_unhandled_input(true)
		
		camera_2d.enabled = true
		camera_2d.make_current()
		car_drive_camera_2d.enabled = false
	else:
		_play_drive_in()
	car_drive_scroller.thief_car.car_entered.connect(_on_car_entered)
	car_drive_scroller.thief_car.car_exited.connect(_on_car_exited)
	car_drive_scroller.thief_car.cookie_dropped.connect(_on_cookie_dropped)


func _play_drive_in() -> void:
	player.set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	player.visible = false
	car_drive_camera_2d.make_current()
	car_drive_scroller.play_drive_in()
	await car_drive_scroller.animation_player.animation_finished
	_on_car_exited()


func _setup_cookie_stashes() -> void:
	var cookie_stashes := get_tree().get_nodes_in_group("cookie_stash")
	available_cookie_count = cookie_stashes.size()
	cookies_label.text = "Cookies: %2d/%2d" % [collected_cookie_count, available_cookie_count]
	for cookie_stash: CookieStash in cookie_stashes:
		cookie_stash.cookie_looted.connect(_on_cookie_looted)


func _setup_masked_by_player_nodes() -> void:
	for node in get_tree().get_nodes_in_group("masked_by_player_vision"):
		if node is CanvasItem:
			node.light_mask = 2
			node.material = masked_by_player_vision_material


func _process(_delta: float) -> void:
	time_label.text = "Time: %s" % format_as_time(level_timer.time_left)


func _on_level_timer_timeout() -> void:
	get_tree().set_pause.call_deferred(true)
	timeout_panel.visible = true


func _on_next_level_button_pressed() -> void:
	get_tree().set_pause.call_deferred(false)
	get_tree().change_scene_to_file(LEVEL_SELECT_UI)


func _on_retry_level_button_pressed() -> void:
	get_tree().set_pause.call_deferred(false)
	get_tree().change_scene_to_file(self.scene_file_path)


func _on_cookie_looted(_from: CookieStash) -> void:
	cookie_loot_panel.visible = true
	inventory_panel.visible = true
	get_tree().paused = true


func _on_cookie_loot_panel_finish_looting() -> void:
	cookie_loot_panel.visible = false
	inventory_panel.visible = false
	get_tree().paused = false


func _on_cookie_loot_panel_cookie_collected(cookie_id: int) -> void:
	player.has_cookie = true
	inventory_panel.add_cookie(cookie_id)


func _on_car_entered() -> void:
	var thief_car := car_drive_scroller.thief_car
	goal_tracker.call("update_mission_goals")
	mission_details._update_ui()
	mission_details.visible = true
	player.set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)
	player.visible = false
	
	car_drive_camera_2d.global_position = camera_2d.global_position
	car_drive_camera_2d.enabled = true
	car_drive_camera_2d.make_current()
	camera_2d.enabled = false
	thief_car.set_process_unhandled_input(false)
	check_for_mission_goals()
	
	var tween := create_tween()
	var car_drive_position := Vector2(1920.0, 1080.0) / 2.0
	tween.tween_property(car_drive_camera_2d, "global_position", car_drive_position, 0.4) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(thief_car.set_process_unhandled_input.bind(true))


func _on_cookie_dropped() -> void:
	if player.has_cookie:
		player.drop_of_cookie()
		inventory_panel.clear_inventory()
		collected_cookie_count += 1
		car_drive_scroller.thief_car.animated_cookie_drop(randi_range(6, 12))
		cookies_label.text = "Cookies: %2d/%2d" % [collected_cookie_count, available_cookie_count]
		check_for_mission_goals()
	else:
		print("no cookies for drop of on cargo bed")


func check_for_mission_goals() -> void:
	if collected_cookie_count >= available_cookie_count:
		var main_goals := level_mission.main_goals()
		main_goals[0].goal_reached = true
		mission_details._update_ui()


func _on_car_exited() -> void:
	var thief_car := car_drive_scroller.thief_car
	thief_car.set_process_unhandled_input(false)
	mission_details.visible = false
	
	var tween := create_tween()
	var car_exit_position := thief_car.global_position
	tween.tween_property(car_drive_camera_2d, "global_position", car_exit_position, 0.4) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func ():
		player.global_position = car_drive_scroller.thief_car.global_position
		player.set_process_mode.call_deferred(Node.PROCESS_MODE_INHERIT)
		player.visible = true
		thief_car.set_process_unhandled_input(true)
		
		camera_2d.enabled = true
		camera_2d.make_current()
		car_drive_camera_2d.enabled = false)


func _on_mission_finished(_mission: LevelMission):
	car_drive_scroller.play_drive_out()
	mission_details.visible = false
	ResourceLoader.load_threaded_request(LEVEL_SELECT_UI)
	await car_drive_scroller.animation_player.animation_finished
	await Global.play_fade_out()
	var loaded_level := ResourceLoader.load_threaded_get(LEVEL_SELECT_UI)
	get_tree().change_scene_to_packed(loaded_level)
	Global.play_fade_in()


static func format_as_time(total_seconds: float) -> String:
	var minutes := floori(int(total_seconds) / 60.0)
	var seconds := int(total_seconds) % 60
	var milliseconds := int((total_seconds - int(total_seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
