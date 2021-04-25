extends Control

var is_fading_out = true
var initial_value = Color(1, 1, 1, 1)
var final_value = Color(1, 1, 1, 0)

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
		1, 
		Tween.TRANS_LINEAR, 
		Tween.EASE_IN_OUT)
	$Subtitle/FadeInOut.start()

func _ready():
	# warning-ignore:return_value_discarded
	$Subtitle/FadeInOut.connect("tween_all_completed", self, "reverse_tween")
	fade()

func _input(event):
	if event is InputEventKey and event.pressed:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Game.tscn")
