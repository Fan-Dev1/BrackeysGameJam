class_name InventoryPanel
extends Container

const INVENTORY_COOKIE_SLOT := preload("res://ui/inventory_cookie_slot.tscn")

@onready var inventory_container: GridContainer = %InventoryContainer


func _ready() -> void:
	clear_inventory()


func clear_inventory() -> void:
	for child in inventory_container.get_children():
		inventory_container.remove_child(child)
		child.queue_free()


func add_cookie(cookie_id: int) -> void:
	var cookie_slot: InventoryCookieSlot = INVENTORY_COOKIE_SLOT.instantiate()
	cookie_slot.set_cookie_id(cookie_id)
	inventory_container.add_child(cookie_slot)
