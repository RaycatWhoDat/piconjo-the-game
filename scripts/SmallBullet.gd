extends "res://scripts/Bullet.gd"

func _init():
	SPEED *= 0.5

func _ready():
	pass

func _on_SmallBullet_body_entered(body):
	var damage = round(BASE_DAMAGE * DAMAGE_MULTIPLIER)
	if body.is_in_group("destructible"):
		body.queue_free()
	elif body.is_in_group("damageable"):
		body.take_damage(damage)
		
	queue_free()
