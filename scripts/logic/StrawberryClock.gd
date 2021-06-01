extends "res://scripts/Boss.gd"

enum BossAction {
	IDLE,
	ATTACKING,
	CHARGING
}

var SmallBullet = preload("res://scenes/SmallBullet.tscn")
var LargeBullet = preload("res://scenes/LargeBullet.tscn")

onready var player_node = get_node("/root/Game/Player")

var move_speed = 100
var entity_name = "StrawberryClock"
var patrol_path
var patrol_points
var patrol_index = 0

var is_attacking = false
var is_charging = false

func is_player_present():
	return player_node.IN_BOSS_FIGHT and player_node.number_of_bosses_killed == 2

func _init():
	GRAVITY = 0

func _ready():
	patrol_path = "/root/Game/Levels/SCPatrolPath"
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()
	#warning-ignore: return_value_discarded
	$AttackDelay.connect("timeout", self, "shoot_at_player")
	
func change_animation(animation_name = null):
	var animation_player_node = get_node(str(entity_name, "Player"))
	var attack_name = "Attack" if is_attacking else "Idle"
	var all_names = [
		"SC",
		attack_name
	]
	
	var current_animation_name = animation_player_node.current_animation
	var next_animation_name = animation_name if animation_name else "%s%s" % all_names
	if animation_player_node.has_animation(next_animation_name):
		if current_animation_name == next_animation_name and animation_player_node.is_playing():
			pass
		else:
			print("Animation changed: %s" % next_animation_name)
			animation_player_node.play(next_animation_name)
			animation_player_node.advance(0)
			if current_animation_name:
				var start_time = animation_player_node.current_animation_position
				animation_player_node.seek(round(min(start_time, animation_player_node.current_animation_length)))
	else:
		print("Missing animation! %s" % next_animation_name)

	
func patrol():
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 50:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	velocity = move_and_slide(velocity)
	
func shoot_at_player():
	is_attacking = true
	velocity = Vector2.ZERO

	if randi() % 10 + 1 > 8:
		charge_and_fire()
	else:
		fire()
	is_attacking = false
	
func charge_and_fire():
	is_charging = true
	$AttackDelay.paused = true
	change_animation("SCAttackCharge")
	yield(get_tree().create_timer(3), "timeout")
	var player_normal = (player_node.global_position - global_position).normalized()
	var player_direction = abs(rad2deg(player_normal.angle()))
	var bullet = LargeBullet.instance()
	bullet.BASE_DAMAGE = 10
	owner.add_child(bullet)
	bullet.global_transform = $StrawberryClockMuzzle.global_transform
	bullet.rotation_degrees = player_direction
	
	$StrawberryClockAudioPlayer.stream = load("res://assets/sounds/StrawberryClockProjectileMove.wav")
	$StrawberryClockAudioPlayer.play(0)
	bullet.connect("tree_exiting", self, "stop_move_sound")
	
	is_charging = false
	$AttackDelay.paused = false
	change_animation()

func stop_move_sound():
	$StrawberryClockAudioPlayer.stop()

func fire():
	change_animation()
	yield(get_tree().create_timer(0.25), "timeout")
	var player_normal = (player_node.global_position - global_position).normalized()
	var player_direction = abs(rad2deg(player_normal.angle()))
	var bullet = SmallBullet.instance()
	owner.add_child(bullet)
	bullet.global_transform = $StrawberryClockMuzzle.global_transform
	bullet.rotation_degrees = player_direction

func _physics_process(_delta):
	if is_player_present():
		if $AttackDelay.is_stopped():
			$AttackDelay.start()
		if not is_charging:
			patrol()

