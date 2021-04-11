extends "res://scripts/Boss.gd"

enum BossAction {
	STANDING,
	ADVANCING,
	RETREATING
}

export (BossAction) var boss_action = BossAction.STANDING

func _physics_process(_delta):
	match boss_action:
		BossAction.STANDING:
			$TankmanPlayer.set_animation("Walking")
			$TankmanPlayer.stop(true)
		BossAction.ADVANCING:
			$TankmanPlayer.set_animation("Walking")
