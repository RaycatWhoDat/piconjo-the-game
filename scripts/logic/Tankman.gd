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

func _init():
	SPEED = 50

func move_towards_player():
	var distance_to_player = global_position.distance_to(player_node.global_position)
	var player_direction = (player_node.global_position - global_position).normalized()
	velocity.x = player_direction.x * SPEED 
	print(distance_to_player, player_direction)

func _physics_process(_delta):
	match boss_action:
		BossAction.STANDING:
			tankman_player.play("Walking")
			tankman_player.advance(0)
			tankman_player.stop(true)
			if player_node.IN_BOSS_FIGHT:
				boss_action = BossAction.ADVANCING
		BossAction.ADVANCING:
			if not tankman_player.is_playing():
				tankman_player.play("Walking")
				tankman_player.advance(0)
			move_towards_player()
