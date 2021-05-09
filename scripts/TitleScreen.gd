extends Control

var is_fading_out = true
var initial_value = Color(1, 1, 1, 0)
var final_value = Color(1, 1, 1, 1)
var fade_duration = 1

onready var crimson_fade = $CrimsonScreen/Fade

func reverse_tween():
	var temp_value = initial_value
	initial_value = final_value
	final_value = temp_value
	is_fading_out = not is_fading_out
	fade()

func fade():
	$Subtitle/FadeInOut.interpolate_property(
		$Subtitle, 
		"modulate", 
		initial_value, 
		final_value, 
		fade_duration, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT)
	$Subtitle/FadeInOut.start()

func _ready():
	crimson_fade.interpolate_property($CrimsonScreen, 
		"color", 
		Color(1, 0.113725, 0.003922, 1), 
		Color(1, 0.113725, 0.003922, 0),
		fade_duration,
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT)
	crimson_fade.start()
	
	var fade_timer = Timer.new()
	fade_timer.set_one_shot(true)
	fade_timer.wait_time = fade_duration
	fade_timer.connect("timeout", self, "start_fade")
	add_child(fade_timer)
	fade_timer.start()

func start_fade():
	# warning-ignore:return_value_discarded
	$Subtitle/FadeInOut.connect("tween_all_completed", self, "reverse_tween")
	fade()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_Q:
			get_tree().quit()
		elif event.scancode == KEY_Z:
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/Game.tscn")
