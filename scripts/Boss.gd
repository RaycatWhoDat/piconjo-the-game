extends Actor

onready var ambiance_player = get_node("/root/Game/AmbientMusicPlayer")

signal boss_killed

func _ready():
	if is_in_group("boss1"):
		HEALTH_POINTS = Constants.BOSS_1_HEALTH_POINTS
	elif is_in_group("boss2"):
		HEALTH_POINTS = Constants.BOSS_2_HEALTH_POINTS
	elif is_in_group("boss3"):
		HEALTH_POINTS = Constants.BOSS_3_HEALTH_POINTS
	elif is_in_group("boss4"):
		HEALTH_POINTS = Constants.BOSS_4_HEALTH_POINTS
	elif is_in_group("boss5"):
		HEALTH_POINTS = Constants.BOSS_5_HEALTH_POINTS
	# warning-ignore: return_value_discarded
	connect("boss_killed", get_node("/root/Game/Player"), "handle_victory")

func disable_boss_area():
	var boss_shape
	if is_in_group("boss1"):
		boss_shape = get_node("/root/Game/Levels/BossArea/BossAreaShape")
	elif is_in_group("boss2"):
		boss_shape = get_node("/root/Game/Levels/BossArea2/BossAreaShape")
	elif is_in_group("boss3"):
		boss_shape = get_node("/root/Game/Levels/BossArea3/BossAreaShape")
	elif is_in_group("boss5"):
		boss_shape = get_node("/root/Game/Levels/BossArea4/BossAreaShape")
	
	if boss_shape:
		boss_shape.disabled = true

func cleanup():
	var camera_node = get_node("/root/Game/Camera")
	var player_node = get_node("/root/Game/Player")
	camera_node.current = true
	player_node.FOLLOW_PLAYER = true
	player_node.IN_BOSS_FIGHT = false
	disable_boss_area()
	emit_signal("boss_killed")

func crossfade_music():
	var music_player = get_node("/root/Game/GlobalMusicPlayer")
	var crossfade_tween = get_node("/root/Game/CrossfadeOut")
	var crossfade_time = 3
	
	ambiance_player.play()
	
	crossfade_tween.stop_all()	
	crossfade_tween.interpolate_property(ambiance_player, 
		"volume_db", 
		ambiance_player.volume_db, 
		-15, 
		crossfade_time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
		
	crossfade_tween.interpolate_property(music_player, 
		"volume_db", 
		music_player.volume_db, 
		-50, 
		crossfade_time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)

	crossfade_tween.start()
	
func die():
	var camera_node = get_node("/root/Game/Camera")
	var player_node = get_node("/root/Game/Player")

#	var shake_tween_node = camera_node.get_node("ScreenShakeTween")
	var camera_tween_node = camera_node.get_node("BossLockTween")
	var tween_duration = 0.5
	var camera_punchout_amount = -0.1
	
#	camera_node.start_shake(3)
	
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
	
	if not ambiance_player.playing:
		crossfade_music()
	
	cleanup()
	queue_free()

func instakill():
	take_damage(HEALTH_POINTS)
	
func take_damage(damage):
	var player_node = get_node("/root/Game/Player")
	if get_name() == "PICO":
		# warning-ignore: return_value_discarded
		get_tree().change_scene("res://scenes/EndingVideo.tscn")
		return
	if player_node.IN_BOSS_FIGHT:		
		flash()
		var health_bar = get_node("/root/Game/UI/BossHealthBar")
		var boss_name = get_node("/root/Game/UI/BossName")

		var flash_timer = Timer.new()
		flash_timer.set_one_shot(true)
		flash_timer.wait_time = 0.08
		flash_timer.connect("timeout", self, "handle_damage", [
			health_bar, 
			boss_name, 
			player_node, 
			damage
		])
		add_child(flash_timer)
		flash_timer.start()

func handle_damage(health_bar, boss_name, player_node, damage):
	HEALTH_POINTS -= damage
	update_health_bar(health_bar, HEALTH_POINTS)
	
	if HEALTH_POINTS <= 0:
		health_bar.visible = false
		boss_name.visible = false
		player_node.number_of_bosses_killed += 1
		call_deferred("die")
	else:	
		unflash()

