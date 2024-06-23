class_name HitBox
extends Area2D

signal hit(hurtBox)

func _init() -> void:
	# 将函数传给区域碰撞函数
	area_entered.connect(_on_area_enterd)

func _on_area_enterd(hurtBox:HurtBox) -> void:
	prints("[Hit] %s => %s" % [owner.name,hurtBox.owner.name])
	hit.emit(hurtBox)
	hurtBox.hurt.emit(self)
#area_entered
