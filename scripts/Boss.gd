extends Actor

func _ready():
	if is_in_group("boss1"):
		HEALTH_POINTS = Constants.BOSS_1_HEALTH_POINTS
	elif is_in_group("boss2"):
		HEALTH_POINTS = Constants.BOSS_2_HEALTH_POINTS
	elif is_in_group("boss3"):
		HEALTH_POINTS = Constants.BOSS_3_HEALTH_POINTS
	elif is_in_group("boss4"):
		HEALTH_POINTS = Constants.BOSS_4_HEALTH_POINTS

func disable_boss_area():
	var boss_shape
	if is_in_group("boss1"):
		boss_shape = get_node("/root/Game/Levels/BossArea/BossAreaShape")
	elif is_in_group("boss2"):
		boss_shape = get_node("/root/Game/Levels/BossArea2/BossAreaShape")
	elif is_in_group("boss3"):
		boss_shape = get_node("/root/Game/Levels/BossArea3/BossAreaShape")
	elif is_in_group("boss4"):
		boss_shape = get_node("/root/Game/Levels/BossArea4/BossAreaShape")
	
	if boss_shape:
		boss_shape.call_deferred("set_disabled", true)

func cleanup():
	var camera_node = get_node("/root/Game/Camera")
	var player_node = get_node("/root/Game/Player")
	camera_node.current = true
	player_node.FOLLOW_PLAYER = true
	player_node.IN_BOSS_FIGHT = false
	disable_boss_area()

func die():
	var camera_node = get_node("/root/Game/Camera")
	var player_node = get_node("/root/Game/Player")
#	var shake_tween_node = camera_node.get_node("ScreenShakeTween")
	var camera_tween_node = camera_node.get_node("BossLockTween")
	var tween_duration = 0.5
	var camera_punchout_amount = -0.25
	
	camera_node.start_shake(3)
	
	camera_tween_node.stop_all()
	camera_tween_node.follow_property(camera_node, 
		"position", 
		camera_node.position, 
		player_node,
		"position",
		tween_duration, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT)
	camera_tween_node.interpolate_property(camera_node, 
		"zoom", 
		camera_node.zoom,
		Vector2(camera_node.zoom.x + camera_punchout_amount, camera_node.zoom.y + camera_punchout_amount), 
		tween_duration, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT)
	camera_tween_node.start()
	cleanup()
	queue_free()

func instakill():
	take_damage(HEALTH_POINTS)
	
func take_damage(damage):
	var player_node = get_node("/root/Game/Player")
	if player_node.IN_BOSS_FIGHT:
		flash()
		var health_bar = get_node("/root/Game/UI/BossHealthBar")
		var boss_name = get_node("/root/Game/UI/BossName")

		HEALTH_POINTS -= damage
		update_health_bar(health_bar)

		yield(get_tree().create_timer(0.08), "timeout")
		
		if HEALTH_POINTS <= 0:
			health_bar.visible = false
			boss_name.visible = false
			player_node.number_of_bosses_killed += 1
			call_deferred("die")
		else:	
			unflash()

