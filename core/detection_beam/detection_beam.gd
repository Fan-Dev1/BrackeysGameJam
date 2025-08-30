@tool
class_name DetectionBeam
extends Node2D

enum Mode { KEEP_ON, KEEP_OFF, BLINK_PATTERN }

@export var controlling_lever: LeverButton
@export var mode := Mode.BLINK_PATTERN : set = set_beam_mode
@export var beam_enabled := true : set = set_beam_enabled
@export var beam_length := 200.0 : set = set_beam_length
## even number = on duration in sec, odd number = off duration in sec[br]
## example: [0.4, 0.2, 1.0, 0.2] <=> on=0.4s -> off=0.2s -> on=1.0s -> off=0.2 -> repeat
@export var blink_pattern := PackedFloat32Array()
var blink_pattern_index := 0

@onready var blink_timer: Timer = $BlinkTimer
@onready var beam_line_2d: Line2D = $BeamLine2D
@onready var laser_ray_cast_2d: RayCast2D = $LaserRayCast2D


func _ready() -> void:
	set_beam_length(beam_length)
	_start_blink_timer()
	if is_controlled_by_lever() and not Engine.is_editor_hint():
		controlling_lever.lever_flipped.connect(_on_lever_flipped)


func _start_blink_timer():
	if Engine.is_editor_hint():
		return
	if blink_pattern.is_empty():
		push_warning("empty_blink_pattern")
		blink_timer.start(2.0)
	else:
		var blink_duration_sec := blink_pattern[blink_pattern_index]
		blink_timer.start(blink_duration_sec)


func _on_blink_timer_timeout() -> void:
	if mode != Mode.BLINK_PATTERN:
		return
	blink_pattern_index += 1
	if blink_pattern_index >= blink_pattern.size():
		blink_pattern_index = 0
		set_beam_enabled(true)
	else:
		set_beam_enabled(not beam_enabled)
	_start_blink_timer()


func set_beam_length(length: float) -> void:
	beam_length = length
	if is_node_ready():
		var target_position := Vector2.RIGHT * beam_length
		laser_ray_cast_2d.set_target_position.call_deferred(target_position)
		draw_beam_to(target_position)


func draw_beam_to(target_position: Vector2) -> void:
	beam_line_2d.clear_points()
	beam_line_2d.add_point(Vector2.ZERO)
	beam_line_2d.add_point(target_position)


func set_beam_enabled(enabled: bool) -> void:
	beam_enabled = enabled
	if is_node_ready():
		beam_line_2d.visible = beam_enabled
		laser_ray_cast_2d.enabled = beam_enabled
		if beam_enabled:
			$LazerStateRect.color = Color.GREEN
		else:
			$LazerStateRect.color = Color.RED


func set_beam_mode(_mode: Mode) -> void:
	mode = _mode
	match mode:
		Mode.KEEP_ON:  set_beam_enabled(true)
		Mode.KEEP_OFF: set_beam_enabled(false)
		Mode.BLINK_PATTERN: _enter_blink_pattern_mode()


func _enter_blink_pattern_mode() -> void:
	if blink_pattern.is_empty():
		push_warning("blink_pattern should contain at least 2 duration periods but was: " + str(blink_pattern.size()))
		set_beam_mode(Mode.KEEP_ON) # fallback to keep
	else:
		blink_pattern_index = 0
		_start_blink_timer()


func _physics_process(_delta: float) -> void:
	if not beam_enabled or Engine.is_editor_hint():
		return
	
	if laser_ray_cast_2d.is_colliding():
		var collision_point := laser_ray_cast_2d.get_collision_point()
		draw_beam_to(to_local(collision_point))
		if laser_ray_cast_2d.get_collider() is Player:
			Global.player_spotted.emit(collision_point, self)
	else:
		var full_length_position := Vector2.RIGHT * beam_length
		draw_beam_to(full_length_position)


func is_controlled_by_lever() -> bool:
	return controlling_lever != null


func _on_lever_flipped(flipped_over: bool) -> void:
	if flipped_over:
		set_beam_mode.call_deferred(Mode.KEEP_ON)
	else:
		set_beam_mode.call_deferred(Mode.KEEP_OFF)
