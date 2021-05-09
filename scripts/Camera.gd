extends Camera2D

onready var screen_shake_tween = $ScreenShakeTween
onready var screen_shake_interval = $ScreenShakeInterval
onready var screen_shake_delay = $ScreenShakeDelay

export (int) var SHAKE_STRENGTH = 3
export (int) var SHAKE_RESET_SPEED = 3

func _ready():
	pass
	
func start_shake(_duration):
	pass
