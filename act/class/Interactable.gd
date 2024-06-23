class_name Interactable
extends Area2D

func _init() -> void:
	set_collision_layer_value(0,true)
	set_collision_mask_value(2,true)
