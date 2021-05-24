extends Area2D

export (int) var SPEED = 600
export var BASE_DAMAGE = 1
export var DAMAGE_MULTIPLIER = 1
var damage = round(BASE_DAMAGE * DAMAGE_MULTIPLIER)

func _physics_process(delta):
	position += transform.x * SPEED * delta

func _on_Bullet_body_shape_entered(_body_id, body, body_shape, _local_shape):
	if body.is_in_group("destructible"):
		body.queue_free()
	elif body.is_in_group("damageable"):
		body.take_damage(damage)
	else:
		var collidables = []
		for index in range(body.get_child_count()):
			var collidable = body.get_child(index)
			if collidable.is_in_group("damageable") or collidable.is_in_group("invincible"):
				collidables.push_back(collidable)
		if collidables[body_shape].is_in_group("damageable"):
			body.take_damage(damage)
		
	queue_free()
