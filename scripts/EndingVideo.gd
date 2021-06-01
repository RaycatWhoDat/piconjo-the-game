extends Control

func _on_VideoPlayer_finished():
	# warning-ignore: return_value_discarded
	get_tree().change_scene("res://scenes/TitleScreen.tscn")
