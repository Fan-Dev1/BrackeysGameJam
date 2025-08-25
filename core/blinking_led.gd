class_name BlinkingLed
extends ColorRect

@export var min_interval := 0.04  # Fastest blink speed
@export var max_interval := 0.50  # Slowest blink speed
@export var timer: Timer

var is_blinking := false


func _process(_delta: float) -> void:
	if (not is_blinking 
			and timer.time_left <= 1.0 
			and timer.time_left > min_interval):
		is_blinking = true
		await blink_cycle()
		is_blinking = false


func blink_cycle() -> void:
	var idle_color = color
	var ratio := timer.time_left / timer.wait_time
	var blink_duration := lerpf(min_interval, max_interval, ratio)
	color = idle_color.inverted()
	await get_tree().create_timer(blink_duration).timeout
	color = idle_color
	
	# cooldown
	ratio = timer.time_left / timer.wait_time
	blink_duration = lerpf(min_interval, max_interval, ratio)
	await get_tree().create_timer(blink_duration).timeout
