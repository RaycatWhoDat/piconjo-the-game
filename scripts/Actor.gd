extends KinematicBody2D
class_name Actor

export (int) var SPEED = 150
export (int) var JUMP_SPEED = -400
export (float) var GRAVITY = 1000.0
export (float, 0, 1.0) var FRICTION = 0.1
export (float, 0, 1.0) var ACCELERATION = 0.25

var velocity = Vector2.ZERO

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
