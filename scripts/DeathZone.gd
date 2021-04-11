extends Area2D

func _on_DeathZone_body_entered(body):
	if body.name == "Player":
		body.handle_death()
