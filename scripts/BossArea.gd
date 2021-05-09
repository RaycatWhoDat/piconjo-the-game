extends Area2D

func setup_health_bar():
	var health_bar = get_node("/root/Game/UI/BossHealthBar")
	var boss_name = get_node("/root/Game/UI/BossName")
	health_bar.max_value = Constants.HEALTH_POINTS[get_name()]
	health_bar.value = health_bar.max_value
	boss_name.text = Constants.BOSS_NAMES[get_name()]
	health_bar.visible = true
	boss_name.visible = true

func crossfade_music():
	var music_player = get_node("/root/Game/GlobalMusicPlayer")
	var ambiance_player = get_node("/root/Game/AmbientMusicPlayer")
	var crossfade_tween = get_node("/root/Game/CrossfadeIn")
	var crossfade_time = 3
	
	var boss_music = Constants.MUSIC[get_name()]
	if not boss_music == "":
		music_player.stream = load(boss_music)
		music_player.volume_db = -50
		music_player.play()
		
		crossfade_tween.stop_all()
		
		crossfade_tween.interpolate_property(ambiance_player, 
			"volume_db", 
			ambiance_player.volume_db, 
			-50, 
			crossfade_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
		
		crossfade_tween.interpolate_property(music_player, 
			"volume_db", 
			music_player.volume_db, 
			-2.5, 
			crossfade_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)

		crossfade_tween.start()

func handle_player_entering_arena(body):
	var player_node = body
	var camera_node = get_node("/root/Game/Camera")
	var tween_node = camera_node.get_node("BossLockTween")
	
	crossfade_music()
	
	var camera_punchout_amount = 0.1
	
	tween_node.stop_all()
	tween_node.interpolate_property(camera_node, 
		"position", 
		camera_node.position, 
		Vector2(camera_node.position.x + 200, camera_node.position.y), 
		1, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT)
	tween_node.interpolate_property(camera_node, 
		"zoom", 
		camera_node.zoom,
		Vector2(camera_node.zoom.x + camera_punchout_amount, camera_node.zoom.y + camera_punchout_amount), 
		1, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT)
	tween_node.start()

	setup_health_bar()
	player_node.FOLLOW_PLAYER = false

func _on_BossArea_body_entered(body):
	if body.is_in_group("player") and not body.IN_BOSS_FIGHT and not $BossAreaShape.disabled:
		var player_node = body
		player_node.IN_BOSS_FIGHT = true
		handle_player_entering_arena(body)
