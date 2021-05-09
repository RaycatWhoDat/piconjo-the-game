extends Area2D

func _on_SwordArea_body_entered(body):
	if not body.is_in_group("invincible"):
		if body.is_in_group("destructible") or body.is_in_group("boss"):
			print(body.name)
			var hit_sfx = preload("res://assets/sounds/PiconjoSwordHit.wav")
			var audio_player = get_node("/root/Game/GlobalSoundPlayer")
			audio_player.set_stream(hit_sfx)
			audio_player.set_volume_db(-15)
			audio_player.play()
		if body.is_in_group("destructible"):
			body.queue_free()
		elif body.is_in_group("boss"):
			var base_damage = 5
			var damage_multiplier = 1
			var damage = round(base_damage * damage_multiplier)
			body.take_damage(damage)
