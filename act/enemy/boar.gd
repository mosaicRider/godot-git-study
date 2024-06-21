extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
	HIT,
}
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var calm_down_timer: Timer = $CalmDownTimer

# 状态
func get_next_state(state:State) -> State:
	if player_checker.is_colliding():
		return State.RUN
		
	match state:
		State.IDLE:
			if state_machine.state_time >2:
				return State.WALK;
		State.WALK:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE;
		State.RUN:
			if calm_down_timer.is_stopped():
				return State.WALK;
		State.HIT:
			pass
	return state

func transition_state(from:State,to:State)-> void:
	#打印动作变化
	prints("[%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<START>",
		State.keys()[to],
	])
	match to:
		State.IDLE:
			animation_player.play("idle")
			if wall_checker.is_colliding():
				direction *= -1
				# 检查器重置检查
				wall_checker.force_raycast_update()
		State.WALK:
			animation_player.play("walk")
			if not floor_checker.is_colliding():
				direction *= -1
				floor_checker.force_raycast_update()
		State.RUN:
			animation_player.play("run")
		State.HIT:
			animation_player.play("hit")

func tick_physics(state:State,delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0,delta)
		State.WALK:
			move(max_speed/3,delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction *= -1
			move(max_speed,delta)
			if player_checker.is_colliding():
				calm_down_timer.start()
		State.HIT:
			move(defualt_gravity,delta)
