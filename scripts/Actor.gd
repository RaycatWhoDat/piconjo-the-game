extends KinematicBody2D
class_name Actor

export (int) var SPEED = 150
export (int) var JUMP_SPEED = -400
export (float) var GRAVITY = 1000.0
export (float, 0, 1.0) var FRICTION = 0.1
export (float, 0, 1.0) var ACCELERATION = 0.25
export (int) var HEALTH_POINTS = 0

var velocity = Vector2.ZERO

func modify_color(color):
	for node in get_children():
		if node is AnimatedSprite:
			node.modulate = color
			
func flash():
	modify_color(Color.red)

func unflash():
	modify_color(Color.white)

func update_health_bar(health_bar):
	var health_tween
	for child in health_bar.get_children():
		if child is Tween:
			health_tween = child
		
	health_tween.interpolate_property(health_bar,
		"value",
		health_bar.value,
		HEALTH_POINTS,
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT)
	health_tween.start()

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.785398, false)
