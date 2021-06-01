extends Control

func go_to_title_screen():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/TitleScreen.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_Q:
			get_tree().quit()
		elif event.scancode == KEY_Z:
			go_to_title_screen()

func _on_VideoPlayer_finished():
	go_to_title_screen()
