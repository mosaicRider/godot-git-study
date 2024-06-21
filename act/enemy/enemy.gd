class_name Enemy
extends CharacterBody2D

enum Direction {
	Left=-1,
	Right=1,
}

@export var direction := Direction.Left:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction
	
@export var max_speed := 180.0 as float
@export var acceleration := 2000.0 as float
var defualt_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
@onready var graphics: Node2D = $Graphics
@onready var state_machine: StateMachine = $StateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer

	
func move(spped:float,delta: float)->void:
	velocity.x = move_toward(velocity.x,spped*direction,acceleration*delta)
	velocity.y += defualt_gravity * delta

	move_and_slide()
