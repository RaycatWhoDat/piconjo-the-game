extends Area2D

func setup_health_bar():
	var health_bar = get_node("/root/Game/UI/BossHealthBar")
	var boss_name = get_node("/root/Game/UI/BossName")
	health_bar.max_value = Constants.HEALTH_POINTS[get_name()]
	health_bar.value = health_bar.max_value
	boss_name.text = Constants.BOSS_NAMES[get_name()]
	health_bar.visible = true
	boss_name.visible = true

func handle_player_entering_arena(body):
	var player_node = body
	var camera_node = get_node("/root/Game/Camera")
	var tween_node = camera_node.get_node("BossLockTween")
	tween_node.stop_all()
	tween_node.interpolate_property(camera_node, 
		"position", 
		camera_node.position, 
		Vector2(camera_node.position.x + 200, camera_node.position.y), 
		1, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT)
	tween_node.start()

	setup_health_bar()
	player_node.FOLLOW_PLAYER = false

func _on_BossArea_body_entered(body):
	if body.name == "Player" and not body.IN_BOSS_FIGHT:
		var player_node = body
		player_node.IN_BOSS_FIGHT = true
		handle_player_entering_arena(body)
