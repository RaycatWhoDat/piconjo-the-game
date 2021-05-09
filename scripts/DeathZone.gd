extends Area2D

func _on_DeathZone_body_entered(body):
	if 'damageable' in body.get_groups():
		print(body.name)
		body.take_damage(body.HEALTH_POINTS)
