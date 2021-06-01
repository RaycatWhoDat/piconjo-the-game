extends "res://scripts/Boss.gd"

export (PackedScene) var Bullet = preload("res://scenes/Bullet.tscn")

export (float, 0.0, 5.0) var JUMP_SPEED_MULTIPLIER = 0.5
export (float, 0.0, 1.0) var BULLET_DELAY_TIME = 0.4
export (int) var MAGIC_LIMIT = 525

onready var skull_kid_player = get_node("SkullKidPlayer")
onready var player_node = get_node("/root/Game/Player")
onready var music_player = get_node("/root/Game/GlobalMusicPlayer")

var entity_name = "SkullKid"
enum MovementState { IDLE, WALK, JUMP }
enum WeaponType { GUN, SWORD }
var movement_names = ["Stand", "Walk", "Jump"]
var weapon_names = ["Gun", "Sword"]
var movement_state = MovementState.IDLE
var weapon_type = WeaponType.GUN

var is_attacking = false
var is_facing_left = true
var directionality = 0

func _init():
	SPEED *= 1.4

func is_player_present():
	return player_node.IN_BOSS_FIGHT and player_node.number_of_bosses_killed == 1

func change_animation():
	var animation_player_node = get_node(str(entity_name, "Player"))
	var movement_name = movement_names[movement_state]
	var attack_name = "Attack" if is_attacking else ""
	var weapon_name = weapon_names[weapon_type]
	var direction_name = "Left" if is_facing_left else ""
	var all_names = [
		"SK", 
		movement_name, 
		attack_name, 
		weapon_name, 
		direction_name
	]
	
	var current_animation_name = animation_player_node.current_animation
	var next_animation_name = "%s%s%s%s%s" % all_names
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


func handle_landing():
	if is_on_floor():
		velocity = Vector2.ZERO
		is_attacking = true
		if is_player_present() and $JumpTimer.time_left <= 0:
			jump()
			$JumpTimer.start()
	else:
		movement_state = MovementState.JUMP
		is_attacking = false

func handle_attacking():
	if weapon_type == WeaponType.GUN:
		if is_attacking and $BulletDelay.time_left <= 0:
			var bullet = Bullet.instance()
			bullet.BASE_DAMAGE = 2
			owner.add_child(bullet)
			bullet.global_transform = $Muzzle.global_transform
			$BulletDelay.stop()
			$BulletDelay.start(BULLET_DELAY_TIME)

func jump():
	if is_on_floor():
		velocity.y -= JUMP_SPEED_MULTIPLIER * GRAVITY

func handle_movement(player_direction):
	if is_on_floor():
		directionality = 0
		movement_state = MovementState.IDLE
		if player_direction >= 90:
			is_facing_left = true
			directionality = -1
		elif player_direction < 90:
			is_facing_left = false
			directionality = 1
	
	change_animation()
	if not is_on_floor():
		velocity.x = lerp(velocity.x, directionality * SPEED, ACCELERATION)

func move_towards_player():
	var player_normal = (player_node.global_position - global_position).normalized()
	var player_direction = abs(rad2deg(player_normal.angle()))
	handle_movement(player_direction)

func _ready():
	$SkullKidPlayer.play("SKStandGunLeft")
	$SkullKidPlayer.advance(0)
	
func _physics_process(_delta):
	if is_player_present():
		handle_landing()
		handle_attacking()
		move_towards_player()
		if not music_player.playing:
			music_player.stream = load("res://assets/music/Korded-ft-Larrynachos.mp3")
			music_player.volume_db = -2.5
			music_player.play()
