extends Camera2D

onready var screen_shake_tween = $ScreenShakeTween
onready var screen_shake_interval = $ScreenShakeInterval
onready var screen_shake_delay = $ScreenShakeDelay

export (int) var SS_STRENGTH = 3
export (int) var SS_RESET_SPEED = 3

var is_shaking = false

func _ready():
	screen_shake_interval.connect("timeout", self, "cancel_shake")
	screen_shake_delay.connect("timeout", self, "shake_camera")

func reset_camera():
	screen_shake_tween.interpolate_property(self, "offset", offset, Vector2.ZERO, SS_RESET_SPEED, Tween.TRANS_SINE, Tween.EASE_OUT)
	screen_shake_tween.start()
	
func shake_camera():
#	if is_shaking and not screen_shake_tween.is_active:
	screen_shake_tween.interpolate_property(self,
		"offset",
		offset, 
		Vector2(rand_range(-SS_STRENGTH, SS_STRENGTH), rand_range(-SS_STRENGTH, SS_STRENGTH)),
		SS_RESET_SPEED, 
		Tween.TRANS_SINE, 
		Tween.EASE_OUT)
	screen_shake_tween.start()

func start_shake(shake_length):
	is_shaking = true
	screen_shake_interval.start(shake_length)
	screen_shake_delay.start(SS_RESET_SPEED)
	
func cancel_shake():
	is_shaking = false
	screen_shake_tween.stop_all()
	reset_camera()
