extends MaestroPlayer

class_name BassPlayer



# References
@onready var rapid_timer = $Timers/RapidTimer


const ORIGAMI_SPEEDB := 450
const DASH_SPEED := 175

# Variables
var buster_speed = 300
var airactiontaken = false
var hovered = false
var hovering = false
var hoverstrength : int
var airdashed
var airdashtime : int
var chargedshots : int
var machinecharge : int

func _init() -> void:
	
	weapon_palette = [
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/bass/palettes/Freeze Frame.png"),
		preload("res://sprites/players/bass/palettes/Poison Cloud.png"),
		preload("res://sprites/players/bass/palettes/Fin Shredder.png"),
		preload("res://sprites/players/bass/palettes/Origami Star.png"),
		preload("res://sprites/players/bass/palettes/Wild Gale.png"),
		preload("res://sprites/players/bass/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/bass/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/bass/palettes/Proto Buster.png"),
		preload("res://sprites/players/bass/palettes/Treble.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Bass Buster.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 1.png"),
		preload("res://sprites/players/bass/palettes/Proto Charge 2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png")
	]
	
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/bass/buster.tscn"),
		preload("res://scenes/objects/players/weapons/bass/blast_jump.tscn"),
		preload("res://scenes/objects/players/weapons/bass/track_2.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/weapons/bass/protoshot1.tscn"),
		preload("res://scenes/objects/players/weapons/bass/protoshot2.tscn")
	]

	weapon_scenes = [
		preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/wild_gale.tscn")
	]
	


func _physics_process(delta: float) -> void:
	check_for_death()
	
	GameState.player.position.x = position.x
	GameState.player.position.y = position.y
	GameState.playerstate = currentState
	if GameState.onscreen_sp_bullets < 0:
		GameState.onscreen_sp_bullets = 0
	if GameState.onscreen_bullets < 0:
		GameState.onscreen_bullets = 0
	if GameState.current_hp > 28:
		GameState.current_hp = 28
	if GameState.weapon_energy[GameState.current_weapon] > GameState.max_weapon_energy[GameState.current_weapon]:
		GameState.weapon_energy[GameState.current_weapon] = GameState.max_weapon_energy[GameState.current_weapon]
	#INPUTS -lynn
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	#this cancels out any floats in the inputs and makes inputs to be purely digital (-1,0,1) rather than analouge
	direction = Vector2(sign(direction.x), sign(direction.y))
	$states.text = "[center]%s[/center]" % STATES.keys()[currentState]
	if !transing:
		match currentState:
			STATES.TELEPORT, STATES.TELEPORT_LANDING:
				teleporting()
				applyGrav(delta)
			STATES.IDLE:
				idle(delta)
				dashProcess()
				checkForFloor()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.IDLE_THROW, STATES.IDLE_SHOOT:
				checkForFloor()
				processJump()
				processShoot()
				processCharge()
				processDamage()
			STATES.IDLE_SHIELD, STATES.PAPER_CUT:
				checkForFloor()
				processShoot()
				processDamage()
			
			STATES.IDLE_AIM, STATES.IDLE_AIM_UP, STATES.IDLE_AIM_DIAG, STATES.IDLE_AIM_DOWN:
				if on_ice == false:
					velocity.x = 0
				else:
					velocity.x = lerpf(velocity.x, 0, delta * ICE_FLOOR_WEIGHT)
				processBuster()
				checkForFloor()
				processJump()
				processShoot()
				processDamage()
				
			STATES.STEP:
				step(delta)
				checkForFloor()
				dashProcess()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.WALK, STATES.WALKING_SHOOT:
				walk()
				dashProcess()
				checkForFloor()
				processJump()
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD, STATES.JUMP_AIM, STATES.JUMP_AIM_UP, STATES.JUMP_AIM_DIAG, STATES.JUMP_AIM_DOWN:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_blaze()
				module_reaper()
			STATES.FALL_START, STATES.FALL, STATES.FALL_SHOOT, STATES.FALL_THROW, STATES.FALL_SHIELD, STATES.FALL_AIM, STATES.FALL_AIM_UP, STATES.FALL_AIM_DIAG, STATES.FALL_AIM_DOWN:
				fall(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_blaze()
				module_gale()
				module_reaper()
			STATES.AIR_DASH:
				module_reaper()
				processDamage()
				module_origami()
			STATES.DASH:
				dashing(delta)
				processJump()
				processCharge()
				ladderCheck()
				processDamage()
				module_origami()
			STATES.LADDER:
				ladder()
				processCharge()
				processShoot()
				processBuster()
				processDamage()
			STATES.HURT:
				hurt()
				applyGrav(delta)
			STATES.DEAD:
				dead()
				
		position.x += wind_push
		animationMatching()
		switchWeapons()
		if currentState != STATES.DEAD:
			move_and_slide()
		if GameState.modules_enabled[WEAPONS.GUERRILLA] == true:
			$states.text = "[center]%s[/center]" % chargedshots
			if machinecharge > 0 and chargedshots < 5:
				machinecharge -= 1
			if machinecharge == 0:
				machinecharge = 60
				chargedshots += 1

func checkForFloor():
	if !is_on_floor():
		currentState = STATES.FALL_START
		$mainCollision.disabled = false
		$slideCollision.disabled = true
	else:
		if airactiontaken == true:
			airactiontaken = false
			slowed = false
		hovered = false
		hovering = false
		airdashed = false

func dashProcess():
	if Input.is_action_just_pressed("dash"):
		if on_ice != true:
			velocity.x = 175 * sprite.scale.x
		currentState = STATES.DASH
		slide_timer.start(0.4)
		FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
		get_parent().add_child(FX)
		if sprite.scale.x == -1:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8
		$Audio/Slide.play()

func dashing(delta):
	if on_ice == false:
		velocity.x = 250 * sprite.scale.x
	else:
		velocity.x = lerpf(velocity.x, sprite.scale.x * 260, delta * 4)
	
	if direction.x != 0:
		if direction.x + sprite.scale.x == 0:
			if $ceilCheck.is_colliding():
				sprite.scale.x = direction.x
			else:
				slide_timer.start(0.001)
	
	if !is_on_floor():
		velocity.x = 0
		currentState = STATES.FALL
		
	if Input.is_action_just_pressed("jump") or !is_on_floor():
		dashdir = sprite.scale.x
		dashjumped = true
	if Input.is_action_just_released("dash"):
		slide_timer.start(0.001)
		
func _on_slide_timer_timeout() -> void:
	if !is_on_floor():
		pass
	if on_ice == false:
		velocity.x = 0
	if direction.x:
		currentState = STATES.WALK
	else:
		currentState = STATES.IDLE

func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
				#buster dont go here lol
			WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			WEAPONS.SMOG:
				busterAnimMatch()
				weapon_smog()
			WEAPONS.SHARK:
				throwAnimMatch()
				weapon_shark()
			WEAPONS.ORIGAMI:
				throwAnimMatch()
				weapon_origami()
			WEAPONS.GALE:
				shieldAnimMatch()
				weapon_gale()
			WEAPONS.GUERRILLA:
				busterAnimMatch()
				weapon_guerilla()
			WEAPONS.CARRY:
				throwAnimMatch()
				weapon_carry()
			WEAPONS.ARROW:
				busterAnimMatch()
				weapon_arrow()
			WEAPONS.PUNK:
				throwAnimMatch()
				weapon_punk()
			WEAPONS.BALLADE:
				throwAnimMatch()
				weapon_ballade()
			WEAPONS.QUINT:
				weapon_quint()

func aimAnimMatch():
	shoot_timer.start()
	if is_on_floor():
		if direction.y == -1:
			currentState = STATES.IDLE_AIM_DOWN
		elif direction.y == 1 and direction.x == 0:
			currentState = STATES.IDLE_AIM_UP
		elif direction.y == 1:
			currentState = STATES.IDLE_AIM_DIAG
		else:
			currentState = STATES.IDLE_AIM
	elif STATES.keys()[currentState].contains("JUMP"):
		if direction.y == -1:
			currentState = STATES.JUMP_AIM_DOWN
		elif direction.y == 1 and direction.x == 0:
			currentState = STATES.JUMP_AIM_UP
		elif direction.y == 1:
			currentState = STATES.JUMP_AIM_DIAG
		else:
			currentState = STATES.JUMP_AIM
	elif STATES.keys()[currentState].contains("FALL"):
		if direction.y == -1:
			currentState = STATES.FALL_AIM_DOWN
		elif direction.y == 1 and direction.x == 0:
			currentState = STATES.FALL_AIM_UP
		elif direction.y == 1:
			currentState = STATES.FALL_AIM_DIAG
		else:
			currentState = STATES.FALL_AIM

func processBuster():
	if Input.is_action_pressed("buster") or (GameState.current_weapon == WEAPONS.BUSTER and Input.is_action_pressed("shoot")):
		aimAnimMatch()
		weapon_buster()

func weapon_buster():
	if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
		if !attack_timer.is_stopped():
			if shot_type == 1:
				no_grounded_movement = true
		else:
			no_grounded_movement = false
		if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
			if Input.is_action_pressed("move_left"):
				sprite.scale.x = -1
			if Input.is_action_pressed("move_right"):
				sprite.scale.x = 1
			
			if rapid_timer.is_stopped() and GameState.onscreen_bullets < 4:
				rapid_timer.start(0.10)
				shot_type = 1
				GameState.onscreen_bullets += 1
				attack_timer.start(0.4)
				projectile = projectile_scenes[0].instantiate()
				get_parent().add_child(projectile)
				projectile.scale.x = sprite.scale.x
				if chargedshots > 0:
					projectile.charged = true
					chargedshots -= 1
				
				
				if GameState.onscreen_bullets == 1 or GameState.onscreen_bullets == 3:
					projectile.frames = 1
				# inputs
				if Input.is_action_pressed("move_up"):
					if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
						projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
						projectile.velocity.y = -(buster_speed * 0.5)
						projectile.position.x = position.x + sprite.scale.x * 14
						projectile.position.y = position.y + -6
					else:
						projectile.velocity.y = -buster_speed
						projectile.position.x = position.x + sprite.scale.x * 2
						projectile.position.y = position.y - 17
				elif Input.is_action_pressed("move_down"):
					projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
					projectile.velocity.y = (buster_speed * 0.5)
					projectile.position.x = position.x + sprite.scale.x * 14
					projectile.position.y = position.y + 10
				else:
					projectile.velocity.x = sign(sprite.scale.x) * buster_speed
					projectile.position.x = position.x + sprite.scale.x * 17
					projectile.position.y = position.y + 2
					
	#		is_dashing = false
			return

func weapon_origami():
	if Input.is_action_just_pressed("shoot") and (GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 2 or GameState.infinite_ammo == true) and GameState.onscreen_sp_bullets < 1:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 2
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  -ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.825
		projectile.velocity.y = -ORIGAMI_SPEEDB * 0.2
		
		projectile = weapon_scenes[0].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.825
		projectile.velocity.y =  ORIGAMI_SPEEDB * 0.2
		
		
		return

# ================
# MODULE FUNCTIONS
# ================

func module_blaze() -> void:
	if (airactiontaken == false) && Input.is_action_just_pressed("jump") && Input.is_action_pressed("move_up") && (GameState.modules_enabled[WEAPONS.BLAZE] == true):
		$Audio/BlastJump.play()
		velocity.y = -275
		slide_timer.stop()
		airactiontaken = true
		slowed = true
		dashjumped = false
		ice_jump = false
		currentState = STATES.JUMP
		projectile = projectile_scenes[1].instantiate()
		get_parent().add_child(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		projectile.velocity.y = 280

func module_smog() -> void:
	if anim.get_current_animation() != "Mist Dash":
		anim.stop()
		anim.play("Mist Dash")
	#Changes Collision
	$MainHitbox.set_disabled(true)
	$SlideHitbox.set_disabled(false)
	
func module_origami() -> void:
	if GameState.modules_enabled[WEAPONS.ORIGAMI] == true:
		if Input.is_action_just_pressed("shoot"):
			velocity.x = 0
			$Audio/ReaperDash.play()
			
			
			projectile = preload("res://scenes/objects/players/weapons/bass/papercut.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.y = position.y
			projectile.position.x = position.x + sprite.scale.x * 12
			projectile.velocity.x = sprite.scale.x * 70
			slide_timer.start(0)
			projectile.scale.x = sprite.scale.x
			currentState = STATES.PAPER_CUT

func module_gale() -> void:
	if GameState.modules_enabled[WEAPONS.GALE] == true:
		if (airactiontaken == false) && (hovered == false) && (hovering == false) && Input.is_action_just_pressed("jump") && !Input.is_action_pressed("move_up"):
			airactiontaken = true
			hovering = true
			slowed = true
			dashjumped = false
			hoverstrength = 230
			ice_jump = false
			
		if (hovering == true) && (hovered == false) && Input.is_action_pressed("jump") && !Input.is_action_pressed("move_up"):
			if hoverstrength > 0:
				velocity.y = WATER_FAST_FALL - hoverstrength
			if hoverstrength > 200:
				velocity.y = 0
			hoverstrength -= 1
			$Audio/Hover.play()
			
		if (hovering == true) && Input.is_action_just_released("jump"):
			hovered = true
			

func module_reaper() -> void:
	if GameState.modules_enabled[WEAPONS.REAPER] == true:
		if (airactiontaken == false) && (airdashed == false) && Input.is_action_just_pressed("dash"):
			airactiontaken = true
			slowed = true
			dashjumped = false
			airdashtime = 25
			ice_jump = false
			$Audio/ReaperDash.play()
			currentState = STATES.AIR_DASH
			
		if (airdashtime > 0) && (airdashed == false) && Input.is_action_pressed("dash"):
			velocity.y = 0
			velocity.x = sprite.scale.x * DASH_SPEED
			if airdashtime == 25 or airdashtime == 20 or airdashtime == 15 or airdashtime == 10 or airdashtime == 5:
				FX = preload("res://scenes/objects/players/weapons/bass/reaper_dash.tscn").instantiate()
				get_parent().add_child(FX)
				FX.position = position
				if sprite.scale.x == -1:
					FX.flip_h = true
			airdashtime -= 1
			
		if (airactiontaken == true) && Input.is_action_just_released("dash") or airdashtime == 0:
			airdashed = true
			airdashtime = -5
			currentState = STATES.FALL_START

func dash_jump(direction, delta):
	if direction.x:
		sprite.scale.x = sign(direction.x)
		if direction.x == dashdir:
			velocity.x = sprite.scale.x * DASH_SPEED
		else:
			velocity.x = sprite.scale.x * MAXSPEED * 0.75
	else:
		velocity.x = 0


func play_start_sound() -> void:
	pass#$Audio/Start.play()


func _on_teleported() -> void:
	pass # Replace with function body.
