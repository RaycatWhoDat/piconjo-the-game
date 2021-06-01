extends "res://scripts/Boss.gd"

onready var player_node = get_node("/root/Game/Player")

var move_speed = 100
var entity_name = "PICO"
var patrol_path
var patrol_points
var patrol_index = 0

func _init():
	GRAVITY = 0
	HEALTH_POINTS = 10

func _ready():
	patrol_path = "/root/Game/Levels/PICOPatrolPath"
	if patrol_path:
		patrol_points = get_node(patrol_path).curve.get_baked_points()

func patrol():
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 50:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	velocity = move_and_slide(velocity)
	

func _physics_process(_delta):
	$Message.visible = not $Message.visible
	if player_node.number_of_bosses_killed >= 3:
		patrol()
