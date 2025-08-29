class_name LevelSlot
extends Button

signal level_mission_selected(level_mission: LevelMission)

@export var level_mission: LevelMission: set = set_level_mission 

@onready var level_label: Label = %LevelLabel
@onready var level_preview_texture_rect: TextureRect = %LevelPreviewTextureRect
@onready var grey_color_rect: ColorRect = %GreyColorRect
@onready var locked_texture_rect: TextureRect = %LockedTextureRect


func _ready() -> void:
	update_ui()


func update_ui() -> void:
	if level_mission == null or not is_node_ready():
		return
	level_label.text = level_mission.level_name
	grey_color_rect.visible = not level_mission.unlocked
	locked_texture_rect.visible = not level_mission.unlocked
	self.disabled = not level_mission.unlocked
	queue_redraw()


func _draw() -> void:
	if button_pressed:
		var border_width := 8.0
		var border_rect := Rect2(Vector2.ZERO, self.size)
		border_rect = border_rect.grow(border_width)
		draw_rect(border_rect, Color.AQUA)


func set_level_mission(_level_mission: LevelMission) -> void:
	level_mission = _level_mission
	update_ui()


func _on_toggled(toggled_on: bool) -> void:
	queue_redraw()
	if toggled_on:
		level_mission_selected.emit(level_mission)
