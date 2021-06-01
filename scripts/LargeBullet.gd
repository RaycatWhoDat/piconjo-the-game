extends Area2D

export (int) var SPEED = 600
export var BASE_DAMAGE = 1
export var DAMAGE_MULTIPLIER = 1

func _physics_process(delta):
	position += transform.x * SPEED * delta

func _on_LargeBullet_body_entered(body):
	var damage = round(BASE_DAMAGE * DAMAGE_MULTIPLIER)
	if body.is_in_group("destructible"):
		body.queue_free()
	elif body.is_in_group("damageable"):
		body.take_damage(damage)
		
	queue_free()
