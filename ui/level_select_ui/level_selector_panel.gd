extends PanelContainer

signal level_selected(level_mission: LevelMission)

const level_slot_scene = preload("res://ui/level_select_ui/level_slot.tscn")

var slot_button_group := ButtonGroup.new()

@onready var level_mission_preloader: ResourcePreloader = $LevelMissionPreloader
@onready var level_grid_container: GridContainer = %LevelGridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slot_button_group.allow_unpress = false
	_setup_level_slots()


func _setup_level_slots() -> void:
	for child in level_grid_container.get_children():
		child.queue_free()
	
	var is_first := true
	for resource_name in level_mission_preloader.get_resource_list():
		var level_mission: LevelMission = level_mission_preloader.get_resource(resource_name)
		if not level_mission is LevelMission:
			push_warning("level_mission_preloader was not a level_mission: " + str(level_mission_preloader))
		
		var level_slot: LevelSlot = level_slot_scene.instantiate()
		level_slot.set_level_mission(level_mission)
		level_slot.level_mission_selected.connect(_on_level_selected)
		level_slot.button_group = slot_button_group
		level_grid_container.add_child(level_slot)
		if is_first:
			level_slot.set_pressed.call_deferred(true)
			is_first = false


func _on_level_selected(level_mission: LevelMission) -> void:
	level_selected.emit(level_mission)
	
