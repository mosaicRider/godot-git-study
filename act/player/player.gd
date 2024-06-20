extends CharacterBody2D

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float;
const RUN_SPEED := 200.0 as float;
const JUMP_SPEED := -350.0 as float;
const ACCELERATION:= RUN_SPEED/0.2;
const AIR_ACCELERATION:= RUN_SPEED/0.02;
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
# 平台掉落时跳起
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var sound: AudioStreamPlayer2D = $Sound

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start();
	# 尽快结束跳跃，形成按的越长，跳的越高的效果（防止在最后落下时，突然按下小跳（此时因为判断松开又有新的跳跃速度加入，所以会进行大跳））
	if event.is_action_released("jump"):
		jump_request_timer.stop();
		if velocity.y < JUMP_SPEED/2: 
			velocity.y  = JUMP_SPEED/2

func _physics_process(delta: float) -> void:
	var drection = Input.get_axis("move_left","move_right");
	# 直接满速
	# velocity.x = drection * RUN_SPEED;
	# 缓缓加速0.2秒
	var acceleration = ACCELERATION if is_on_floor() else AIR_ACCELERATION;
	velocity.x = move_toward(velocity.x,drection * RUN_SPEED,ACCELERATION * delta);
	velocity.y += gravity * delta;
	
	var canjump = is_on_floor() or coyote_timer.time_left >0 ;
	var should_jump = canjump && jump_request_timer.time_left >0 ;
	if should_jump:
		velocity.y = JUMP_SPEED;
		coyote_timer.stop();
		jump_request_timer.stop();
		
	if is_on_floor():
		#if is_zero_approx(drection):
		# 加入缓缓加速防止滑行
		if is_zero_approx(drection) && is_zero_approx(velocity.x):
			animation_player.play("idle");
			if sound!=null && not sound.playing:
				sound.play();
		else:
			animation_player.play("running");
	else:
		animation_player.play("jump");
	
	if not is_zero_approx(drection):
		sprite_2d.flip_h = drection<0;
		
	var was_on_floor = is_on_floor();
	move_and_slide();
	
	if is_on_floor() != was_on_floor:
		if was_on_floor && not should_jump:
			coyote_timer.start();
		else:
			coyote_timer.stop();
