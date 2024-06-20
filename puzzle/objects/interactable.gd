extends Area2D
class_name Interactable

signal interact

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not event.is_action_pressed("interact"):
		return
	_interact()

func _interact():
	emit_signal("interact")
