extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
	HIT,
	DIE,
}

const Hit_SPPED := 520.0
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var calm_down_timer: Timer = $CalmDownTimer
@onready var stats: Stats = $Stats
@onready var pend_damage:= Array([], TYPE_OBJECT, &"RefCounted", Damage)

func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	return player_checker.get_collider() is Player

# 状态
func get_next_state(state:State) -> State:
	if stats.health == 0:
		return State.DIE
	#prints("get_next_state",pend_damage.size())
	if pend_damage.size() > 0:
		return State.HIT
	match state:
		State.IDLE:
			if can_see_player():
				return State.RUN
			if state_machine.state_time >2:
				return State.WALK;
		State.WALK:
			if can_see_player():
				return State.RUN
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE;
		State.RUN:
			if not can_see_player and calm_down_timer.is_stopped():
				return State.WALK;
		State.HIT:
			if not animation_player.is_playing():
				return State.RUN
	return state

func transition_state(from:State,to:State)-> void:
	#打印动作变化
	#prints("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
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
			stats.health -= pend_damage.map(func(d): return d.amount).reduce(func(d): return d||0)
			if stats.health == 0:
				queue_free()
			var dir :Vector2 = pend_damage[-1].source.global_position.direction_to(global_position)
			velocity.x = dir.x * Hit_SPPED
			if dir.x > 0:
				direction = Direction.Left
			else:
				direction = Direction.Right
			pend_damage.clear();
			#prints(pend_damage.size())
		State.DIE:
			animation_player.play("die")

func tick_physics(state:State,delta: float) -> void:
	match state:
		State.IDLE,State.HIT,State.DIE:
			move(0.0,delta)
		State.WALK:
			move(max_speed/3,delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction *= -1
			move(max_speed,delta)
			if can_see_player():
				calm_down_timer.start()


func _on_hurt_box_hurt(hitBox: HitBox) -> void:
	var damage = Damage.new()
	damage.amount = 1
	damage.source = hitBox.owner
	pend_damage.append(damage)
