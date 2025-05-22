extends MaestroPlayer

class_name BassPlayer



# References
@onready var rapid_timer = $Timers/RapidTimer


const ORIGAMI_SPEEDB := 450
var AIR_DASH_SPEED := 155
var DASH_SPEED = 225
	
# Variables
var buster_speed = 300
var airactiontaken = false
var hovered = false
var hovering = false
var hoverstrength : int
var airdashed
var airdashtime : int
var chargedshots : int
var machinechargetimer : int
var smogchargetimer : int

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
		preload("res://sprites/players/weapons/ScytheCharge1.png"),
		preload("res://sprites/players/bass/palettes/Ultimate.png")
	]
	
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/bass/buster.tscn"),
		preload("res://scenes/objects/players/weapons/bass/blast_jump.tscn"),
		preload("res://scenes/objects/players/weapons/bass/track_2.tscn"),
		preload("res://scenes/objects/players/weapons/bass/papercut.tscn"),
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
	
func set_current_weapon_palette() -> void:
	if GameState.current_weapon == 0 and GameState.ultimate == true:
		sprite.material.set_shader_parameter("palette", weapon_palette[21])
	else:
		sprite.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

func _physics_process(delta: float) -> void:
	check_for_death()
	
	GameState.player.position.x = position.x
	GameState.player.position.y = position.y
	GameState.playerstate = currentState
	if GameState.onscreen_sp_bullets < 0:
		GameState.onscreen_sp_bullets = 0
	if GameState.onscreen_bullets < 0:
		GameState.onscreen_bullets = 0
	if GameState.current_hp > GameState.max_HP:
		GameState.current_hp = GameState.max_HP
	if GameState.weapon_energy[GameState.current_weapon] > GameState.max_WE:
		GameState.weapon_energy[GameState.current_weapon] = GameState.max_WE
	#INPUTS -lynn
	direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	#this cancels out any floats in the inputs and makes inputs to be purely digital (-1,0,1) rather than analouge
	direction = Vector2(sign(direction.x), sign(direction.y))
	$states.text = "[center]%s[/center]" % STATES.keys()[currentState]
	if !transing:
		match currentState:
			STATES.TELEPORT, STATES.TELEPORT_LANDING:
				if GameState.ultimate == true:
					sprite.material.set_shader_parameter("palette", weapon_palette[21])
				animationMatching()
				teleporting()
			STATES.IDLE:
				idle(delta)
				animationMatching()
				dashProcess()
				checkForFloor()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_video()
			STATES.IDLE_THROW, STATES.IDLE_SHOOT:
				checkForFloor()
				animationMatching()
				processJump()
				processShoot()
				processCharge()
				processDamage()
				module_video()
				if on_ice == true:
					velocity.x = lerpf(velocity.x, 0, delta * ICE_FLOOR_WEIGHT)
			STATES.IDLE_SHIELD, STATES.PAPER_CUT:
				checkForFloor()
				animationMatching()
				processShoot()
				processDamage()
				module_video()
			
			STATES.IDLE_AIM, STATES.IDLE_AIM_UP, STATES.IDLE_AIM_DIAG, STATES.IDLE_AIM_DOWN:
				if on_ice == false:
					velocity.x = 0
				else:
					velocity.x = lerpf(velocity.x, 0, delta * ICE_FLOOR_WEIGHT)
				processBuster()
				animationMatching()
				checkForFloor()
				processJump()
				processShoot()
				processDamage()
				module_video()
				
			STATES.STEP:
				step(delta)
				animationMatching()
				checkForFloor()
				dashProcess()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_video()
			STATES.WALK:
				walk()
				animationMatching()
				dashProcess()
				checkForFloor()
				processJump()
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_video()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD, STATES.JUMP_AIM, STATES.JUMP_AIM_UP, STATES.JUMP_AIM_DIAG, STATES.JUMP_AIM_DOWN:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
				module_gale()
				module_blaze()
				module_reaper()
				module_video()
			STATES.AIR_DASH:
				module_reaper()
				animationMatching()
				processDamage()
				module_origami()
				module_video()
			STATES.DASH:
				dashing(delta)
				animationMatching()
				processJump()
				processCharge()
				ladderCheck()
				processDamage()
				module_smog()
				module_origami()
				module_video()
			STATES.SLIDE:
				$mainCollision.set_disabled(true)
				$slideCollision.set_disabled(false)
				animationMatching()
				dashing(delta)
				processJump()
				processCharge()
				$hurtboxArea/mainHurtbox.set_disabled(true)
				$hurtboxArea/slideHurtbox.set_disabled(true)
				DmgQueue = 0
				
			STATES.LADDER:
				ladder()
				#ladderAnimMatch()
				processCharge()
				processShoot()
				processBuster()
				processDamage()
				module_video()
			STATES.HURT:
				hurt()
				animationMatching()
				applyGrav(delta)
			STATES.DEAD:
				dead()
				animationMatching()
				
		if GameState.freezeframe == false:
			position.x += wind_push
		switchWeapons()
		if currentState != STATES.DEAD:
			move_and_slide()
		if is_on_floor():
			standing = true
		else:
			standing = false
		
		if GameState.modules_enabled[GameState.WEAPONS.SMOG] == true:
			if currentState != STATES.SLIDE:
				if smogchargetimer < 5 and GameState.smogcharge < 18:
					smogchargetimer += 1
				if smogchargetimer == 5:
					smogchargetimer = 0
					GameState.smogcharge += 1
		if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true:
			if machinechargetimer > 0 and GameState.machinecharge < 5:
				machinechargetimer -= 1
			if machinechargetimer == 0:
				machinechargetimer = 60
				GameState.machinecharge += 1

func checkForFloor():
	if !is_on_floor():
		currentState = STATES.JUMP
		$mainCollision.disabled = false
	else:
		if airactiontaken == true:
			airactiontaken = false
			slowed = false
		hovered = false
		hovering = false
		airdashed = false

func processJump():
	if GameState.inputdisabled == false:
		if Input.is_action_just_pressed("jump"): # G: Down+Jump restriction removed... AGAIN
			if !is_on_floor() and currentState == STATES.SLIDE:
				currentState = STATES.JUMP
			else:
				velocity.y = JUMP_VELOCITY
				currentState = STATES.JUMP
				$Audio/Jump.play()
				
			slide_timer.stop()
			$hurtboxArea/mainHurtbox.set_disabled(false)
			$mainCollision.disabled = false
			JumpHeight = 0

func dashProcess():
	if Input.is_action_just_pressed("dash") && direction.y != 1: # G: Up+Dash restriction added... AGAIN
		if on_ice != true:
			velocity.x = 175 * sprite.scale.x
		currentState = STATES.DASH
		slide_timer.start(0.4)
		FX = preload("res://scenes/objects/players/dash_trail.tscn").instantiate()
		add_sibling(FX)
		if sprite.scale.x == -1:
			FX.scale.x = -1
			FX.position.x = position.x + 15
		else:
			FX.position.x = position.x - 15
		FX.position.y = position.y+8
		$Audio/Slide.play()

func dashing(delta):
	if on_ice == false:
		velocity.x = DASH_SPEED * sprite.scale.x
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
		currentState = STATES.JUMP
		
	if Input.is_action_just_pressed("jump") or !is_on_floor():
		dashdir = sprite.scale.x
		dashjumped = true
	if Input.is_action_just_released("dash"):
		slide_timer.start(0.001)
		
func _on_slide_timer_timeout() -> void:
	if $ceilCheck.is_colliding():
		print("keep sliding")
		slide_timer.start(0.1)
	else:
		if !is_on_floor():
			pass
		if on_ice == false:
			velocity.x = 0
		if $mainCollision.disabled == true:
			$mainCollision.disabled = false
		if direction.x:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE

func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
				#buster dont go here lol
			GameState.WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			GameState.WEAPONS.VIDEO:
				weapon_video()
			GameState.WEAPONS.SMOG:
				busterAnimMatch()
				weapon_smog()
			GameState.WEAPONS.SHARK:
				#throwAnimMatch()
				weapon_shark()
			GameState.WEAPONS.ORIGAMI:
				throwAnimMatch()
				weapon_origami()
			GameState.WEAPONS.GALE:
				shieldAnimMatch()
				weapon_gale()
			GameState.WEAPONS.GUERRILLA:
				busterAnimMatch()
				weapon_guerilla()
			GameState.WEAPONS.CARRY:
				throwAnimMatch()
				weapon_carry()
			GameState.WEAPONS.ARROW:
				busterAnimMatch()
				weapon_arrow()
			GameState.WEAPONS.PUNK:
				throwAnimMatch()
				weapon_punk()
			GameState.WEAPONS.BALLADE:
				throwAnimMatch()
				weapon_ballade()
			GameState.WEAPONS.QUINT:
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
			
func busterAnimMatch():
	shoot_timer.start()
	if currentState != STATES.DASH and is_on_floor():
		if on_ice == false:
			velocity.x = 0
		currentState = STATES.IDLE_SHOOT
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHOOT

func processBuster():
	if Input.is_action_pressed("buster") or (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")):
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
			
			if rapid_timer.is_stopped() and (GameState.onscreen_bullets < 4 or (GameState.upgrades_enabled[3] == true and GameState.onscreen_bullets < 6)):
				rapid_timer.start(0.10)
				shot_type = 1
				GameState.onscreen_bullets += 1
				attack_timer.start(0.4)
				projectile = projectile_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.scale.x = sprite.scale.x
				if GameState.machinecharge > 0:
					projectile.charged = true
					GameState.machinecharge -= 1
					machinechargetimer = 60
					$Audio/Machine.play()
				else:
					if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true:
						$Audio/Machine2.play()
					else:
						$Audio/Buster.play()
				
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
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB
		
		projectile = weapon_scenes[0].instantiate()
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.6
		projectile.velocity.y =  -ORIGAMI_SPEEDB * 0.4
		
		projectile = weapon_scenes[0].instantiate()
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 9)
		projectile.position.y = position.y + 2
		projectile.scale.x = -sprite.scale.x
		projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEEDB * 0.825
		projectile.velocity.y = -ORIGAMI_SPEEDB * 0.2
		
		projectile = weapon_scenes[0].instantiate()
		add_sibling(projectile)
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
	if (airactiontaken == false) && Input.is_action_just_pressed("jump") && Input.is_action_pressed("move_up") && (GameState.modules_enabled[GameState.WEAPONS.BLAZE] == true):
		$Audio/BlastJump.play()
		velocity.y = -275
		slide_timer.stop()
		airactiontaken = true
		slowed = true
		dashjumped = false
		ice_jump = false
		currentState = STATES.JUMP
		projectile = projectile_scenes[1].instantiate()
		add_sibling(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y
		projectile.velocity.y = 280

func module_video():
	if Input.is_action_just_pressed("dash") && Input.is_action_pressed("move_up") && (GameState.onscreen_track2s == 0) && (GameState.modules_enabled[GameState.WEAPONS.VIDEO] == true):
		$Audio/BlastJump.play()
		projectile = projectile_scenes[2].instantiate()
		add_sibling(projectile)
		projectile.sprite.scale.x = sprite.scale.x
		projectile.position.x = position.x
		projectile.position.y = position.y+2
		GameState.onscreen_track2s += 1
		print(GameState.onscreen_track2s)

func module_smog() -> void:
	if Input.is_action_pressed("move_down") and GameState.modules_enabled[GameState.WEAPONS.SMOG] == true:
		if GameState.smogcharge == 18:
			currentState = STATES.SLIDE
			GameState.smogcharge = 0
			$hurtboxArea/mainHurtbox.set_disabled(true)
			$hurtboxArea/slideHurtbox.set_disabled(true)
		
	
func module_origami() -> void:
	if GameState.modules_enabled[GameState.WEAPONS.ORIGAMI] == true:
		if Input.is_action_just_pressed("shoot"):
			velocity.x = 0
			$Audio/ReaperDash.play()
			
			
			projectile = projectile_scenes[3].instantiate()
			add_sibling(projectile)
			projectile.position.y = position.y
			projectile.position.x = position.x + sprite.scale.x * 12
			projectile.velocity.x = sprite.scale.x * 70
			slide_timer.start(0)
			projectile.scale.x = sprite.scale.x
			currentState = STATES.PAPER_CUT

func module_gale() -> void:
	if GameState.modules_enabled[GameState.WEAPONS.GALE] == true:
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
	if GameState.modules_enabled[GameState.WEAPONS.REAPER] == true:
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
			velocity.x = sprite.scale.x * AIR_DASH_SPEED
			if airdashtime % 5 == 0:
				FX = preload("res://scenes/objects/players/weapons/bass/reaper_dash.tscn").instantiate()
				add_sibling(FX)
				FX.position = position
				if sprite.scale.x == -1:
					FX.flip_h = true
			airdashtime -= 1
			
		if airactiontaken == true && (Input.is_action_just_released("dash") or airdashtime == 0):
			airdashed = true
			airdashtime = -5
			currentState = STATES.JUMP

func play_start_sound() -> void:
	pass#$Audio/Start.play()


func _on_teleported() -> void:
	pass # Replace with function body.
