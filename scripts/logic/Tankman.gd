extends "res://scripts/Boss.gd"

enum BossAction {
	STANDING,
	ADVANCING,
	RETREATING
}

onready var tankman_player = get_node("TankmanPlayer")
onready var player_node = get_node("/root/Game/Player")
export (BossAction) var boss_action = BossAction.STANDING

var is_attacking = false
var cannon_delay = 1
var pistol_delay = 0.1
var cannon_range = 150

func _init():
	SPEED = 60

func fire_cannon():
	if $CannonTimer.is_stopped():
		change_state(BossAction.STANDING)
		velocity = Vector2.ZERO
		toggle_attacking()
		tankman_player.play("Fire (Primary)")
		tankman_player.advance(0)
		# warning-ignore:return_value_discarded
		$CannonTimer.connect("timeout", self, "change_state", [BossAction.ADVANCING])
		tankman_player.connect("animation_finished", self, "toggle_attacking")
		$CannonTimer.start(cannon_delay)

func toggle_attacking(_animation_name = null):
	is_attacking = not is_attacking

func change_state(action):
	boss_action = action
	if action == BossAction.RETREATING:
		SPEED = 45
	else:
		SPEED = 60

func fire_pistol():
	pass

func move_towards_player():
	var distance_to_player = global_position.distance_to(player_node.global_position)
	var player_normal = (player_node.global_position - global_position).normalized()
	velocity.x = player_normal.x * SPEED
	var player_direction = sign(rad2deg(player_normal.angle()))
	print(player_direction)
	if player_direction == -1:
		boss_action = BossAction.ADVANCING
		SPEED = 60
		if distance_to_player < cannon_range:
			fire_cannon()
	elif player_direction == 1:
		boss_action = BossAction.RETREATING
		SPEED = 45
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
			move_towards_player()
