extends Area2D

export (int) var SPEED = 600

func _physics_process(delta):
	position += transform.x * SPEED * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("destructible"):
		body.queue_free()
	if body.is_in_group("boss"):
		var base_damage = 1
		var damage_multiplier = 1
		var damage = round(base_damage * damage_multiplier)
		body.take_damage(damage)
	if not body.is_in_group("permeable"):
		# print(body.name)
		# Bullets aren't generated on this layer so, it only sees the packed scene
		queue_free()
