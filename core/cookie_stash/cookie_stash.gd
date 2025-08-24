class_name CookieStash 
extends Area2D

signal cookie_taken(from: CookieStash)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		cookie_taken.emit(self)
		body.take_cookie_from(self)
		queue_free()
