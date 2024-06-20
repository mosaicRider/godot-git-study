extends Area2D

@export var vec:Vector2=Vector2(5,5);
var init_pos;
# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("Ball");
	init_pos = position;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position= position+vec;

func reset():
	if vec.x<0:
		Score.score1 += 1;
		vec.x = 5;
	else:
		Score.score2 += 1;
		vec.x = -5;
	position = init_pos;
	pass
