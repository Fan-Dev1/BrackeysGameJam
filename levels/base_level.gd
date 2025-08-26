class_name Level 
extends Node2D

@export var masked_by_player_vision_material: Material

var available_cookie_count := 0
var collected_cookie_count := 0

@onready var player: Player = $Player
@onready var level_timer: Timer = $LevelTimer
@onready var cookies_label: Label = %CookiesLabel
@onready var time_label: Label = %TimeLabel

@onready var level_complete_panel: PanelContainer = %LevelCompletePanel
@onready var timeout_panel: PanelContainer = %TimeoutPanel
@onready var cookie_loot_panel: CookieLootPanel = %CookieLootPanel
@onready var inventory_panel: InventoryPanel = %InventoryPanel


func _ready() -> void:
	$CanvasModulate.visible = true
	timeout_panel.visible = false
	level_complete_panel.visible = false
	cookie_loot_panel.visible = false
	inventory_panel.visible = false
	_setup_cookie_stashes()
	_setup_masked_by_player_nodes()


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


func _on_exit_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if player.has_cookie:
		player.drop_of_cookie()
		inventory_panel.clear_inventory()
		collected_cookie_count += 1
		cookies_label.text = "Cookies: %2d/%2d" % [collected_cookie_count, available_cookie_count]
	
	if collected_cookie_count >= available_cookie_count:
		on_level_completed()


func on_level_completed():
	get_tree().set_pause.call_deferred(true)
	level_complete_panel.visible = true


func _on_level_timer_timeout() -> void:
	get_tree().set_pause.call_deferred(true)
	timeout_panel.visible = true


func _on_next_level_button_pressed() -> void:
	Global.load_next_level()


func _on_retry_level_button_pressed() -> void:
	Global.retry_level()


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


static func format_as_time(total_seconds: float) -> String:
	var minutes := floori(int(total_seconds) / 60.0)
	var seconds := int(total_seconds) % 60
	var milliseconds := int((total_seconds - int(total_seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]
