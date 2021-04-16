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

var pistol_delay = 0.1
var pistol_range = 200

func _init():
	SPEED = full_speed

func _ready():
	# warning-ignore:return_value_discarded
	cannon_timer.connect("timeout", self, "change_state", [BossAction.ADVANCING])
	tankman_player.connect("animation_finished", self, "toggle_attacking")

func attack(timer, delay):
	var firing_animation
	if boss_action == BossAction.ADVANCING:
		firing_animation = "Fire (Primary)"
	elif boss_action == BossAction.RETREATING:
		firing_animation = "Fire (Secondary) (Horizontal)"

	if timer.is_stopped():
		change_state(BossAction.STANDING)
		velocity = Vector2.ZERO
		toggle_attacking()
		tankman_player.play(firing_animation)
		tankman_player.advance(0)
		timer.start(delay)
#		if firing_animation == "Fire (Primary)":
		var cannonball = Cannonball.instance()
		owner.add_child(cannonball)
		cannonball.global_transform = $CannonMuzzle.global_transform
	elif "Secondary" in firing_animation and pistol_timer.time_left == 0:
		change_state(BossAction.STANDING)
		velocity = Vector2.ZERO
		var bullet = Bullet.instance()
		owner.add_child(bullet)
		bullet.global_transform = $PistolMuzzle.global_transform

func fire_cannon():
	attack(cannon_timer, cannon_delay)

func fire_pistol():
	attack(pistol_timer, pistol_delay)
	
func toggle_attacking(_animation_name = null):
	is_attacking = not is_attacking

func change_state(action):
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
	if player_direction >= 90:
		boss_action = BossAction.ADVANCING
		SPEED = full_speed
		if distance_to_player < cannon_range:
			fire_cannon()
	elif player_direction < 90:
		boss_action = BossAction.RETREATING
		SPEED = reduced_speed
		if distance_to_player < pistol_range:
			fire_pistol()
			
func _physics_process(_delta):
	match boss_action:
		BossAction.STANDING:
			if not is_attacking:
				tankman_player.play("Walking")
				tankman_player.advance(0)
				tankman_player.stop(true)
				if player_node.IN_BOSS_FIGHT:
					change_state(BossAction.ADVANCING)
		BossAction.ADVANCING:
			if not tankman_player.is_playing():
				tankman_player.play("Walking")
				tankman_player.advance(0)
			if not is_attacking:
				move_towards_player()
		BossAction.RETREATING:
			tankman_player.play("Fire (Secondary) (Horizontal)")
			tankman_player.advance(0)
			if not is_attacking:
				move_towards_player()
