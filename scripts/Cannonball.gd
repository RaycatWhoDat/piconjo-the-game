extends Area2D

export (int) var SPEED = 600
export var BASE_DAMAGE = 5
export var DAMAGE_MULTIPLIER = 2
var damage = round(BASE_DAMAGE * DAMAGE_MULTIPLIER)
var velocity = Vector2(-350, -150)

func _physics_process(delta):
	velocity.y += gravity * delta
	position += velocity * delta

func _on_Cannonball_body_entered(body):
	if body.is_in_group("destructible"):
		body.queue_free()
	elif body.is_in_group("damageable"):
		body.take_damage(damage)
		
	queue_free()
