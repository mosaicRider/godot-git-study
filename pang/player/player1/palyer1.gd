extends Area2D

@export var x = 5;
@export var speed = 10;
signal abc;
# Called when the node enters the scene tree for the first time.
func _ready():
	# 延时
	var time = get_tree().create_timer(5);
	await  time.timeout;
	# 信号事件调用
	self.connect("abc",Callable(self,"a"));
	emit_signal("abc");
	pass # Replace with function body.

func a():
	$sound.play();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for i in get_overlapping_areas():
		pass
	var y1 = Input.get_action_strength(_get_action_str(1))*speed;
	var y2 = Input.get_action_strength(_get_action_str(-1))*speed;
	var y3 = position.y + y2-y1;
	if y3>24&&y3<624:
		position.y = position.y + y2-y1;
	pass
	
func _get_action_str(data:int):
	if x>0 && data>0:
		return "move_up";
	if x>0 && data<0:
		return "move_down";
	if x<0 && data>0:
		return "move_up2";
	else:
		return "move_down2";


func _on_area_entered(area):
	if area.is_in_group("Ball"):
		emit_signal("abc",12);
		$sound.play();
		area.vec.x=x;
