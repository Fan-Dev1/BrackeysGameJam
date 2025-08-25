class_name CookieLootPanel
extends Container

signal cookie_collected(cookie_id: int)
signal finish_looting

@onready var choices_container: HBoxContainer = %ChoicesContainer


func _ready() -> void:
	for choice_index in choices_container.get_child_count():
		var child: BaseButton = choices_container.get_child(choice_index)
		_randomize_cookie_choice(choice_index)
		child.pressed.connect(_on_cookie_choice_button_pressed.bind(choice_index))


func _randomize_cookie_choice(choice_index: int) -> void:
	var cookie_id := randi_range(1, 99)
	var cookie_slot := get_cookie_slot(choice_index)
	cookie_slot.set_cookie_id(cookie_id)


func _on_cookie_choice_button_pressed(choice_index: int) -> void:
	var cookie_slot := get_cookie_slot(choice_index)
	cookie_collected.emit(cookie_slot.cookie_id)
	_randomize_cookie_choice(choice_index)


func _on_finish_looting_button_pressed() -> void:
	finish_looting.emit()


func get_cookie_slot(choice_index: int) -> InventoryCookieSlot:
	var child: BaseButton = choices_container.get_child(choice_index)
	return child.get_child(0) as InventoryCookieSlot
