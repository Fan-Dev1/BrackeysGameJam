@tool
class_name VisionCone
extends Area2D

signal body_spotted(event: BodySpottedEvent)


@export var vision_cone_config: VisionConeConfig : set = set_vision_cone_config
var vison_cone_changed := true

@onready var vision_polygon: Polygon2D = %VisionPolygon
@onready var vision_collision_polygon: CollisionPolygon2D = %VisionCollisionPolygon
@onready var ray_cast_2d: RayCast2D = %RayCast2D


func _ready() -> void:
	vison_cone_changed = true


func _update_vision_cone() -> void:
	ray_cast_2d.target_position = Vector2(vision_cone_config.radius, 0.0)
	var cone_polygon := vision_cone_config.new_cone_area_polygon()
	vision_collision_polygon.polygon = cone_polygon
	vision_polygon.polygon = cone_polygon
	vision_polygon.color = vision_cone_config.color


func _physics_process(delta: float) -> void:
	vision_polygon.visible = self.monitoring
	_scan_vision_cone()
	
	if vison_cone_changed:
		_update_vision_cone.call_deferred()
		vison_cone_changed = false


func _scan_vision_cone() -> void:
	for body: Node2D in get_overlapping_bodies():
		ray_cast_2d.target_position = ray_cast_2d.to_local(body.global_position)
		ray_cast_2d.force_raycast_update()
		var vision_obscured := ray_cast_2d.get_collider() != body
		if not vision_obscured:
			var body_spotted_event := BodySpottedEvent.new()
			body_spotted_event.collider = ray_cast_2d.get_collider()
			body_spotted_event.collision_point = ray_cast_2d.get_collision_point()
			body_spotted.emit(body_spotted_event)


func set_vision_cone_config(_vision_cone_config: VisionConeConfig) -> void:
	if vision_cone_config != null:
		vision_cone_config.changed.disconnect(_on_vision_cone_config_changed)
	vision_cone_config = _vision_cone_config
	vision_cone_config.changed.connect(_on_vision_cone_config_changed)
	self.vison_cone_changed = true


func _on_vision_cone_config_changed() -> void:
	self.vison_cone_changed = true


class BodySpottedEvent:
	var collider: Node2D
	var collision_point: Vector2
