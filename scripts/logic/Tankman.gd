extends "res://scripts/Boss.gd"

enum BossAction {
	STANDING,
	ADVANCING,
	RETREATING
}

onready var tankman_player = get_node("TankmanPlayer")
onready var cannon_timer = get_node("CannonTimer")
onready var pistol_timer = get_node("PistolTimer")
onready var player_node = get_node("/root/Game/Player")

export (PackedScene) var Cannonball = preload("res://scenes/Cannonball.tscn")
export (PackedScene) var Bullet = preload("res://scenes/Bullet.tscn")
export (BossAction) var boss_action = BossAction.STANDING

var is_attacking = false
var full_speed = 60
var reduced_speed = 35

var cannon_delay = 1
var cannon_range = 250
var muzzle_velocity = 350

var pistol_delay = 0.25
var horizontal_pistol_range = 200
var vertical_pistol_range = 100

func _init():
	SPEED = full_speed

func _ready():
	# warning-ignore:return_value_discarded
	cannon_timer.connect("timeout", self, "change_state", [BossAction.ADVANCING, false])
	pistol_timer.connect("timeout", self, "change_state", [BossAction.RETREATING, false])

func attack(timer, delay):
	var firing_animation
	var is_close_range = global_position.distance_to(player_node.global_position) < vertical_pistol_range
	if boss_action == BossAction.ADVANCING:
		firing_animation = "Fire (Primary)"
	elif boss_action == BossAction.RETREATING:
		if is_close_range:
			firing_animation = "Fire (Secondary) (Vertical)"
		else:
			firing_animation = "Fire (Secondary) (Horizontal)"

	if timer.is_stopped():
		change_state(BossAction.STANDING, true)
		velocity = Vector2.ZERO
		if "Primary" in firing_animation:
			$TankmanAudioPlayer.stream = load("res://assets/sounds/TankmanUgh.wav")
			$TankmanAudioPlayer.volume_db = -2.5
			$TankmanAudioPlayer.play()
			yield(get_tree().create_timer($TankmanAudioPlayer.stream.get_length()), "timeout")
			tankman_player.play(firing_animation)
			tankman_player.advance(0)
			timer.start(delay)
			$TankmanAudioPlayer.stream = load("res://assets/sounds/TankmanCannon.wav")
			$TankmanAudioPlayer.volume_db = -5
			$TankmanAudioPlayer.play()
			yield(get_tree().create_timer(0.2), "timeout")
			var cannonball = Cannonball.instance()
			owner.add_child(cannonball)
			cannonball.global_transform = $CannonMuzzle.global_transform
		elif "Secondary" in firing_animation:
			tankman_player.play(firing_animation)
			tankman_player.advance(0)
			timer.start(delay)
			var bullet = Bullet.instance()
			owner.add_child(bullet)
			bullet.global_transform = $PistolMuzzle.global_transform
			bullet.rotation_degrees = 0
			if "Vertical" in firing_animation:
				bullet.rotation_degrees = 45 

func fire_cannon():
	call_deferred("attack", cannon_timer, cannon_delay)

func fire_pistol():
	call_deferred("attack", pistol_timer, pistol_delay)

func change_state(action, attacking):
	$TankmanAudioPlayer.stop()
	$TankmanAudioPlayer.volume_db = 0
	is_attacking = attacking
	boss_action = action
	if action == BossAction.RETREATING:
		SPEED = reduced_speed
	else:
		SPEED = full_speed

func move_towards_player():
	var distance_to_player = global_position.distance_to(player_node.global_position)
	var player_normal = (player_node.global_position - global_position).normalized()
	velocity.x = player_normal.x * SPEED
	var player_direction = abs(rad2deg(player_normal.angle()))
	if player_direction >= 90 and distance_to_player < cannon_range:
		fire_cannon()
	elif player_direction < 90 and distance_to_player < horizontal_pistol_range:
		fire_pistol()
			
func _physics_process(_delta):
	if not is_attacking:
		tankman_player.play("Walking")
		tankman_player.advance(0)
		match boss_action:
			BossAction.STANDING:
				tankman_player.stop(true)
				if player_node.IN_BOSS_FIGHT:
					change_state(BossAction.ADVANCING, false)
			BossAction.ADVANCING, BossAction.RETREATING:
				move_towards_player()
