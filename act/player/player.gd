class_name Player
extends CharacterBody2D

var defualt_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
const RUN_SPEED := 200.0 as float
const JUMP_SPEED := -380.0 as float
const WALL_JUMP_SPEED := Vector2(500.0,-380.0)
const ACCELERATION:= RUN_SPEED/0.2
const AIR_ACCELERATION:= RUN_SPEED/0.1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
# 平台掉落时跳起
@onready var coyote_timer: Timer = $CoyoteTimer
# 预输入跳跃
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var graphics: Node2D = $Graphics
@onready var hand_checker: RayCast2D = $Graphics/HandChecker
@onready var foot_checker: RayCast2D = $Graphics/FootChecker
@onready var state_machine: StateMachine = $StateMachine

# 因状态机代码调整，导致跳跃变得迟钝，解决办法，第一帧关掉重力
var is_first_tick := false
enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	WALL_JUMP,
}
const GROUND_STATES := [State.IDLE,State.RUNNING,State.LANDING]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") && jump_request_timer :
		jump_request_timer.start()
	# 尽快结束跳跃，形成按的越长，跳的越高的效果（防止在最后落下时，突然按下小跳（此时因为判断松开又有新的跳跃速度加入，所以会进行大跳））
	if event.is_action_released("jump") && jump_request_timer:
		jump_request_timer.stop()
		if velocity.y < JUMP_SPEED/2: 
			velocity.y  = JUMP_SPEED/2

func stand(gravity:float,delta: float)->void:
	var acceleration := ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x,0.0,acceleration*delta)
	velocity.y += gravity * delta

	move_and_slide()
	
func move(gravity:float,delta: float)->void:
	var drection = Input.get_axis("move_left","move_right")
	# 直接满速
	# velocity.x = drection * RUN_SPEED
	# 缓缓加速0.2秒
	var acceleration = ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x,drection * RUN_SPEED,ACCELERATION * delta)
	velocity.y += gravity * delta
	
	# 动画转向
	if not is_zero_approx(drection):
		# sprite_2d.flip_h = drection< 0
		graphics.scale.x = 1 if drection> 0 else -1

	move_and_slide()
	
func tick_physics(state:State,delta: float) -> void:
	match state:
		State.IDLE:
			move(defualt_gravity,delta)
		State.RUNNING:
			move(defualt_gravity,delta)
		State.JUMP:
			move(0.0 if is_first_tick else defualt_gravity,delta)
		State.FALL:
			move(defualt_gravity,delta)
		State.LANDING:
			stand(defualt_gravity,delta)
		State.WALL_SLIDING:
			graphics.scale.x = get_wall_normal().x
			move(defualt_gravity/3,delta)
		State.WALL_JUMP:
			graphics.scale.x = get_wall_normal().x
			if state_machine.state_time < 0.1:
				stand(0.0 if is_first_tick else defualt_gravity,delta)
			else:
				stand(defualt_gravity,delta)
	
	is_first_tick = false
	
func transition_state(from:State,to:State)-> void:
	#打印动作变化
	#prints("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_SPEED
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATES:
				coyote_timer.start()
		State.LANDING:
			animation_player.play("landing")
		State.WALL_SLIDING:
			animation_player.play("wall_sliding")
		State.WALL_JUMP:
			animation_player.play("jump")
			velocity = WALL_JUMP_SPEED
			velocity.x *= get_wall_normal().x
			jump_request_timer.stop()
	
	#蹬墙时，世界减速
	#if to == State.WALL_JUMP:
		#Engine.time_scale = 0.9
	#if from == State.WALL_JUMP:
		#Engine.time_scale = 1.0

	is_first_tick = true

# 状态
func get_next_state(state:State) -> State:
	var canjump = is_on_floor() or coyote_timer.time_left >0
	var should_jump = canjump && jump_request_timer.time_left >0
	if should_jump:
		return State.JUMP
		
	var drection = Input.get_axis("move_left","move_right")
	#if is_zero_approx(drection):
	# 加入缓缓加速防止滑行
	var is_still:= is_zero_approx(drection) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if not is_on_floor():
				return State.FALL
			if not is_still:
				return State.RUNNING
		State.RUNNING:
			if not is_on_floor():
				return State.FALL
			if is_still:
				return State.IDLE
		State.JUMP:
			if velocity.y>=0:
				return State.FALL
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
			if can_wall_sliding():
				return State.WALL_SLIDING
		State.LANDING:
			if not is_still:
				return State.RUNNING
			if not animation_player.is_playing():
				return State.IDLE
		State.WALL_SLIDING:
			if jump_request_timer.time_left > 0 and state_machine.state_time > 0.1:
				return State.WALL_JUMP
			if is_on_floor():
				return State.IDLE
			if not is_on_wall():
				return State.FALL
		State.WALL_JUMP:
			if can_wall_sliding() and not is_first_tick:
				return State.WALL_JUMP
			if velocity.y>=0:
				return State.FALL
	return state

func can_wall_sliding() -> bool:
	return is_on_wall() and hand_checker.is_colliding() and foot_checker.is_colliding()
