extends Actor

export (PackedScene) var Bullet = preload("res://scenes/Bullet.tscn")

export (float, 0.0, 5.0) var JUMP_SPEED_MULTIPLIER = 0.3
export (int) var MAX_EXTRA_JUMPS = 1
export (float, 0.0, 1.0) var BULLET_DELAY_TIME = 0.25
export (float, 0.0, 1.0) var EXTRA_JUMP_DECAY = 0.75
export (float) var ABOUT_FACE_MOVEMENT_DECAY = 10
export (bool) var IN_BOSS_FIGHT = false
export (bool) var FOLLOW_PLAYER = true
export (int) var MAGIC_LIMIT = 525

var entity_name = "Piconjo"
enum MovementState { IDLE, WALK, JUMP }
enum WeaponType { GUN, SWORD }
var movement_names = ["Idle", "Walk", "Jump"]
var weapon_names = ["Gun", "Sword"]
var player_movement_state = MovementState.IDLE
var entity_weapon_type = WeaponType.GUN

var extra_jumps = MAX_EXTRA_JUMPS
var is_attacking = false
var is_facing_left = false
var number_of_bosses_killed = 0

func change_animation(movement_state, weapon_type):
	var animation_player_node = get_node(str(entity_name, "Player"))
	var movement_name = movement_names[movement_state]
	var attack_name = "Attack" if is_attacking else ""
	var weapon_name = weapon_names[weapon_type]
	var direction_name = "Left" if is_facing_left else ""
	var all_names = [
		entity_name, 
		movement_name, 
		attack_name, 
		weapon_name, 
		direction_name
	]
	
	var current_animation_name = animation_player_node.current_animation
	var next_animation_name = "%s%s%s%s%s" % all_names
	if animation_player_node.has_animation(next_animation_name):
		if current_animation_name == next_animation_name and animation_player_node.is_playing():
			pass
		else:
			print("Animation changed: %s" % next_animation_name)
			animation_player_node.play(next_animation_name)
			animation_player_node.advance(0)
			if current_animation_name:
				var start_time = animation_player_node.current_animation_position
				animation_player_node.seek(round(min(start_time, animation_player_node.current_animation_length)))

func jump():
	if is_on_floor():
		velocity.y -= JUMP_SPEED_MULTIPLIER * GRAVITY
	elif extra_jumps > 0:
		velocity.y = 0
		velocity.y -= JUMP_SPEED_MULTIPLIER * GRAVITY * EXTRA_JUMP_DECAY
		extra_jumps -= 1

func switch_weapons():
	var switch_sfx
	# DEV: Generalization in progress...
	var audio_player_node = get_node(str(entity_name, "AudioPlayer"))
	
	if entity_weapon_type == WeaponType.GUN:
		entity_weapon_type = WeaponType.SWORD
		switch_sfx = preload("res://assets/sounds/PiconjoSwitchSword.wav")
	else:
		entity_weapon_type = WeaponType.GUN
		switch_sfx = preload("res://assets/sounds/PiconjoSwitchGun.wav")
		
	audio_player_node.set_stream(switch_sfx)
	audio_player_node.play()

func handle_attacking():
	if entity_weapon_type == WeaponType.GUN:
		if is_attacking and $BulletDelay.time_left <= 0:
			var bullet = Bullet.instance()
			owner.add_child(bullet)
			bullet.transform = $Muzzle.global_transform
			$BulletDelay.stop()
			$BulletDelay.start(BULLET_DELAY_TIME)
	elif entity_weapon_type == WeaponType.SWORD:
		pass

func handle_movement():
	var directionality = 0
	var primary_force = ACCELERATION
	
	if is_on_floor():
		player_movement_state = MovementState.WALK
	
	# Can't move while attacking with sword...?
	if entity_weapon_type == WeaponType.GUN or entity_weapon_type == WeaponType.SWORD: # and not is_attacking:
		if Input.is_action_pressed("ui_left"):
			is_facing_left = true
			directionality = -1
		elif Input.is_action_pressed("ui_right"):
			is_facing_left = false
			directionality = 1
		
	var walk_delta = directionality * SPEED
	
	if directionality == 0:
		if is_on_floor():
			player_movement_state = MovementState.IDLE
		primary_force = FRICTION
		
	is_attacking = Input.is_action_pressed("p1_attack")
		
	velocity.x = lerp(velocity.x, walk_delta, primary_force)

func handle_input():
	change_animation(player_movement_state, entity_weapon_type)
	
	if Input.is_action_just_pressed("p1_jump"):
		jump()
	
	if Input.is_action_just_pressed("p1_switch"):
		switch_weapons()
	
	if Input.is_action_just_pressed("ui_restart"):
		handle_death()

	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("ui_instakill_boss"):
		if IN_BOSS_FIGHT:
			var boss_nodes = get_tree().get_nodes_in_group(str("boss", number_of_bosses_killed + 1))
			for boss_node in boss_nodes:
				boss_node.instakill()

func handle_death():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func handle_jumping():
	if is_on_floor():
		velocity.y = 0
		extra_jumps = MAX_EXTRA_JUMPS
	else:
		player_movement_state = MovementState.JUMP

func take_damage(damage):
	var health_bar = get_node("/root/Game/UI/PlayerHealthBar")
	flash()
	HEALTH_POINTS -= damage
	update_health_bar(health_bar)
	if HEALTH_POINTS <= 0:
		handle_death()
	else:
		unflash()

func get_bottom_of_camera(camera_node):
	var first_position = camera_node.get_position()
	var center_position = camera_node.get_camera_screen_center()
	var vertical_spacing = center_position.y - first_position.y
	return center_position.y + vertical_spacing

func is_camera_at_bottom(camera_node):
	return get_bottom_of_camera(camera_node) >= MAGIC_LIMIT

func handle_camera():
	var camera_node = get_node("/root/Game/Camera")

	if FOLLOW_PLAYER:
		camera_node.position.x = position.x
		camera_node.position.y = min(position.y, MAGIC_LIMIT)

func _physics_process(_delta):
	var tween_node = get_node("/root/Game/Camera/BossLockTween")
	
	handle_movement()
	handle_jumping()
	handle_input()
	handle_attacking()
	
	if not tween_node.is_active():
		handle_camera()

