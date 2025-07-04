extends MaestroPlayer

class_name CopyRobotPlayer

# Variables
var recoil : int
var busterflashtimer : int = 1
var sharkcharge : int
var bustercharge : int
var sakugarne : bool = false
var busterspeed

func _init() -> void:
	JUMP_HEIGHT = 13
	default_projectile_offset = Vector2(18, 2)
	projectile_scenes = [
		preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/carry.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/arrow.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/cr_fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/sakugarne.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/buster_ultimate.tscn")
	]

	weapon_palette = [
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Scorch Barrier.png"),
		preload("res://sprites/players/copy_robot/palettes/Freeze Frame.png"),
		preload("res://sprites/players/copy_robot/palettes/Poison Cloud.png"),
		preload("res://sprites/players/copy_robot/palettes/Fin Shredder.png"),
		preload("res://sprites/players/copy_robot/palettes/Origami Star.png"),
		preload("res://sprites/players/copy_robot/palettes/Wild Gale.png"),
		preload("res://sprites/players/copy_robot/palettes/Rolling Bomb.png"),
		preload("res://sprites/players/copy_robot/palettes/Boomerang Scythe.png"),
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/players/copy_robot/palettes/Carry.png"),
		preload("res://sprites/players/copy_robot/palettes/Super Arrow.png"),
		preload("res://sprites/players/copy_robot/palettes/Mirror Buster.png"),
		preload("res://sprites/players/copy_robot/palettes/Screw Crusher.png"),
		preload("res://sprites/players/copy_robot/palettes/Ballade Cracker.png"),
		preload("res://sprites/players/copy_robot/palettes/Sakugarne.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX1.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX2.png"),
		preload("res://sprites/players/weapons/ScytheCharge0.png"),
		preload("res://sprites/players/weapons/ScytheCharge1.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge0.png"),
		preload("res://sprites/players/copy_robot/palettes/SharkCharge1.png"),
		preload("res://sprites/players/copy_robot/palettes/Ultimate.png")
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



#So basically what this new state machine does is that it organizes every state into a little chunk that'll execute the functions it's meant to each frame. This way you won't need to have the
#function that applies gravity need to specify to only apply it during certain states since it will only execute on the correct states. It's also just nicer to look at.

func set_current_weapon_palette() -> void:
	if GameState.current_weapon == 0 and GameState.ultimate == true:
		sprite.material.set_shader_parameter("palette", weapon_palette[23])
	else:
		sprite.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

func _physics_process(delta: float) -> void:
	$ChargeFX.material.set_shader_parameter("palette", sprite.material.get_shader_parameter("palette"))
	$SharkChargeFX.material.set_shader_parameter("palette", sprite.material.get_shader_parameter("palette"))
	$ScytheChargeFX.material.set_shader_parameter("palette", sprite.material.get_shader_parameter("palette"))
		
	if recoil != 0:
		if recoil < 0:
			position.x -= 1
			recoil += 1
		if recoil > 0:
			position.x += 1
			recoil -= 1
	check_for_death()
	
	if GameState.upgrades_enabled[15] == true:
		busterspeed = 125
	else:
		busterspeed = 0
	
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
				teleporting()
				animationMatching()
			STATES.IDLE, STATES.IDLE_SHOOT:
				idle(delta)
				animationMatching()
				slideProcess()
				checkForFloor()
				processJump()
				processShoot()
				ladderCheck()
				processDamage()
			STATES.IDLE_THROW, STATES.IDLE_FIN_SHREDDER:
				checkForFloor()
				animationMatching()
				processJump()
				processShoot()
				
				processDamage()
			STATES.IDLE_SHIELD, STATES.IDLE_DOUBLE_FIN_SHREDDER:
				checkForFloor()
				animationMatching()
				processShoot()
				processDamage()
				
			STATES.STEP:
				step(delta)
				animationMatching()
				checkForFloor()
				slideProcess()
				processJump()
				processShoot()
				ladderCheck()
				processDamage()
			STATES.WALK, STATES.WALKING_SHOOT:
				walk()
				animationMatching()
				slideProcess()
				checkForFloor()
				processJump()
				allowLeftRight(delta)
				processShoot()
				
				ladderCheck()
				processDamage()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				
				ladderCheck()
				processDamage()
			STATES.SLIDE:
				sliding(delta)
				animationMatching()
				if !$ceilCheck.is_colliding():
					processJump()
				
				ladderCheck()
				processDamage()
			STATES.LADDER:
				ladder()
				ladderInput()
				ladderAnimate()
				
				processBuster()
				processDamage()
			STATES.LADDER_SHOOT, STATES.LADDER_THROW, STATES.LADDER_SHIELD:
				velocity.y = 0
				ladderInput()
				
				processShoot()
				processDamage()
				animationMatching()
			STATES.HURT:
				hurt()
				animationMatching()
				applyGrav(delta)
			STATES.DEAD:
				dead()
				animationMatching()
			STATES.VICTORY:
				victory(delta)
			
		processCharge()
		if GameState.freezeframe == false and STATES.keys()[currentState].contains("LADDER") == false:
			position.x += wind_push
			if velocity.y > WATER_JUMP_VELOCITY:
				velocity.y -= fan_push
				if velocity.y > 0:
					velocity.y -= fan_push
		switchWeapons()
		if currentState != STATES.DEAD:
			move_and_slide()
		if currentState != STATES.VICTORY and victorydemo == true:
			currentState = STATES.VICTORY
		if currentState != STATES.LADDER:
			ladderticks = 0
		if currentState != STATES.WARPING and warping == 1:
			velocity.x = 0
			velocity.y = 0
			currentState = STATES.WARPING
		elif currentState != STATES.WARP2 and warping == 2:
			currentState = STATES.WARP2
			$Timers/StateTimer.start(0.35)
		elif currentState == STATES.WARP2 and $Timers/StateTimer.is_stopped():
			warping = 0
			currentState = STATES.IDLE
		if is_on_floor():
			standing = true
		else:
			standing = false

func processJump():
	if GameState.inputdisabled == false:
		if currentState == STATES.SLIDE:
			JumpHeight = -2
		if Input.is_action_just_pressed("jump") && direction.y != -1:
			if !is_on_floor() and currentState == STATES.SLIDE:
				currentState = STATES.JUMP
			else:
				if in_water == true:
					velocity.y = WATER_JUMP_VELOCITY
				else:
					velocity.y = JUMP_VELOCITY
				
				currentState = STATES.JUMP
				$Audio/Jump.play()
				
			slide_timer.stop()
			$hurtboxArea/mainHurtbox.set_disabled(false)
			$mainCollision.disabled = false
			if JumpHeight >= 0:
				JumpHeight = 0
		
func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing && GameState.inputdisabled == false:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
				#buster stuff doesn't go here now
			GameState.WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			GameState.WEAPONS.VIDEO:
				shieldAnimMatch()
				weapon_video()
			GameState.WEAPONS.SMOG:
				busterAnimMatch()
				weapon_smog()
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

func processCharge():
	if weaponflashtimer < 2:
		weaponflashtimer += 1
	else:
		weaponflashtimer = 0
		
	if busterflashtimer < 2:
		busterflashtimer += 1
	else:
		busterflashtimer = 0
	
	
	if bustercharge > 32:
		if busterflashtimer == 1:
			sprite.material.set_shader_parameter("palette", weapon_palette[17])
		if busterflashtimer != 1:
			set_current_weapon_palette()
	if bustercharge > 102:
		if busterflashtimer == 2:
			sprite.material.set_shader_parameter("palette", weapon_palette[18])
		
			
	if currentWeapon == GameState.WEAPONS.REAPER:
		if ScytheCharge > 19:
			if weaponflashtimer == 1:
				sprite.material.set_shader_parameter("palette", weapon_palette[19])
			if weaponflashtimer != 1 and bustercharge < 32:
				set_current_weapon_palette()
		if ScytheCharge > 69:
			if weaponflashtimer == 2:
				sprite.material.set_shader_parameter("palette", weapon_palette[20])
		if ScytheCharge == 0 and bustercharge == 0:
			set_current_weapon_palette()
			
	if currentWeapon == GameState.WEAPONS.SHARK:
		if sharkcharge > 0:
			if weaponflashtimer == 1:
				sprite.material.set_shader_parameter("palette", weapon_palette[21])
			if weaponflashtimer != 1 and bustercharge < 32:
				set_current_weapon_palette()
		if sharkcharge > 35:
			if weaponflashtimer == 2:
				sprite.material.set_shader_parameter("palette", weapon_palette[22])
		if sharkcharge == 0 and bustercharge == 0:
			set_current_weapon_palette()
	
	if Input.is_action_pressed("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			GameState.WEAPONS.REAPER:
				weapon_reaper()
			GameState.WEAPONS.SHARK:
				weapon_shark()
				
	elif Input.is_action_just_released("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			
			GameState.WEAPONS.REAPER:
				throwAnimMatch()
				weapon_reaper()
			GameState.WEAPONS.SHARK:
				weapon_shark()
				
	if (Input.is_action_pressed("shoot") or Input.is_action_pressed("buster")) && !transing:
		if currentWeapon == GameState.WEAPONS.BUSTER or Input.is_action_pressed("buster"):
			weapon_cbuster()
	elif (Input.is_action_just_released("shoot") or Input.is_action_just_released("buster")) && !transing:
			weapon_cbuster()
			
	if Input.is_action_just_released("buster") && !transing:
			weapon_cbuster()
			

# ================
# WEAPON FUNCTIONS
# ================
func weapon_cbuster():
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if GameState.inputdisabled == false:
			if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3 or (GameState.upgrades_enabled[2] == true and GameState.onscreen_bullets < 5)):
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 1
				if GameState.ultimate == false:
					BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn", Vector2((350 if !GameState.upgrades_enabled[15] else 450) + busterspeed, 0))
					$Audio/Buster1.play()
				
				else:
					BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn", Vector2((350 if !GameState.upgrades_enabled[15] else 450) + busterspeed, 0))
					$Audio/Buster2.play()
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				busterAnimMatch()
				return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3 or (GameState.upgrades_enabled[2] == true and GameState.onscreen_bullets < 5)):
			if currentState == STATES.LADDER and direction.x != 0:
				sprite.scale.x = direction.x
			
			if bustercharge < 32: # no Charge
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
			if bustercharge >= 32 and bustercharge < 102: # medium charge
				if GameState.inputdisabled == false:
					attack_timer.start(0.3)
					GameState.onscreen_bullets += 1
					if GameState.ultimate == false:
						BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn", Vector2(350 + busterspeed ,0))
						$Audio/Buster2.play()
					else:
						if direction.y == 0:
							BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn", Vector2(450,0))
						else:
							BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn", Vector2(360, -90 * direction.y))
						
						$Audio/Buster3.play()
					busterAnimMatch()
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
			if bustercharge >= 102: # da big boi
				if GameState.inputdisabled == false:
					attack_timer.start(0.3)
				
					
					GameState.onscreen_bullets += 1
					
					
					if GameState.ultimate == false:
						BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn", Vector2(350+busterspeed,0))
					else:
						BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_ultimate.tscn", Vector2(350+busterspeed,0))
					$Audio/Buster3.play()
					busterAnimMatch()
					if GameState.upgrades_enabled[11] and direction.y != 0:
						projectile.velocity.y = direction.y * (projectile.velocity.x * 0.2) * -sprite.scale.x
						projectile.velocity.x *= 0.8
					
					
					
					projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
					add_sibling(projectile)
					projectile.position.x = position.x + (sprite.scale.x * 18)
					projectile.position.y = position.y + 2
					
					if currentState != STATES.LADDER and currentState != STATES.LADDER_SHOOT:
						position.x -= sprite.scale.x * 2
						recoil = -sprite.scale.x * 4
					
				bustercharge = 0
				$ChargeFX.play("none")
				
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
	if ((GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster")):
		if bustercharge < 111:
			if GameState.upgrades_enabled[12] and busterflashtimer == 2:
				bustercharge += 1
			bustercharge += 1
				
			if bustercharge == 32:
				$ChargeFX.play("charge1")
				$Audio/Charge1.play()
			if bustercharge == 108:
				$ChargeFX.play("charge2")
				$Audio/Charge1.stop()
				$Audio/Charge2.play()
				$Audio/Charge2.volume_linear = 1
			if bustercharge > 108 and $Audio/Charge2.volume_linear >= 0:
				$Audio/Charge2.volume_linear -= 0.01
		else:
			bustercharge = 110
	else:
		bustercharge = 0
		$ChargeFX.play("none")
				
		$Audio/Charge1.stop()
		$Audio/Charge2.stop()
		set_current_weapon_palette()
		return
		
func weapon_shark():
	if Input.is_action_just_released("shoot"):
		print("released")
		$SharkChargeFX.play("none")
				
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and is_on_floor() and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 3 or GameState.infinite_ammo == true):
			if sharkcharge < 35: #Uncharged. Single Fin Shredder

				anim.seek(0)
				shot_type = 4
				GameState.onscreen_sp_bullets += 1
				shoot_timer.start(0.65)
				velocity.x = 0
				currentState = STATES.IDLE_FIN_SHREDDER
				
				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn", Vector2(1, 15), Vector2(15, -4))
				
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 3

			if sharkcharge > 35: #Charged. Double Fin Shredder!
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 4
				GameState.onscreen_sp_bullets += 1
				shoot_timer.start(0.75)
				velocity.x = 0
				currentState = STATES.IDLE_DOUBLE_FIN_SHREDDER
				anim.seek(0)
				shot_type = 5
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = projectile_scenes[7].instantiate()
				add_sibling(projectile)

				projectile.position.x = position.x + sprite.scale.x * 35
				projectile.position.y = position.y + 2
				
				projectile.velocity.x = sprite.scale.x * 0.1
				projectile.scale.x = sprite.scale.x

			sharkcharge = 0

	if !Input.is_action_pressed("shoot"):
		sharkcharge = 0

	if sharkcharge >= 35 && (GameState.weapon_energy[GameState.WEAPONS.SHARK] < 6 and GameState.infinite_ammo == false):
		sharkcharge = 2

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 0 or GameState.infinite_ammo == true):
		print("pressed")
		if sharkcharge == 1:
			$SharkChargeFX.play("charge1")
				
		if sharkcharge < 78:
			sharkcharge += 1
			if sharkcharge == 36:
				$SharkChargeFX.play("charge2")
				$Audio/Charge1.play()
		else:
			sharkcharge = 77
	else:
		sharkcharge = 0
		$SharkChargeFX.play("none")
		$Audio/Charge1.stop()
		$Audio/Charge2.stop()
		set_current_weapon_palette()
		return
		
func weapon_quint():
	if Input.is_action_just_pressed("shoot") and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.QUINT] > 1 or GameState.infinite_ammo == true):
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[8].instantiate()
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y - 40
		projectile.scale.x = sprite.scale.x
		return
	return
	
func play_start_sound() -> void:
	pass#$Audio/Start.play() #M: Why the fuck did you do this one man


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass # Replace with function body.


func _on_hurtbox_area_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.


func _on_shoot_timer_timeout() -> void:
	if STATES.keys()[currentState].contains("IDLE"):
		currentState = STATES.IDLE
	elif STATES.keys()[currentState].contains("WALK"):
		var getFrame = anim.current_animation_position
		currentState = STATES.WALK
		anim.seek(getFrame)
	elif STATES.keys()[currentState].contains("JUMP"):
		currentState = STATES.JUMP
	elif STATES.keys()[currentState].contains("LADDER"):
		$AnimationPlayer.play("LADDER-1-IDLE")
		currentState = STATES.LADDER

func victory(delta):
	if deathtime < 80 or deathtime > 81:
		deathtime += 1
	
	if deathtime == 80:
		$AnimationPlayer.play("WALK")
		if position.x > GameState.middleroom:
			sprite.scale.x = -1
			velocity.x = MAXSPEED * -1
		if position.x < GameState.middleroom:
			sprite.scale.x = 1
			velocity.x = MAXSPEED * 1
		deathtime += 1
	
	if deathtime == 81 and (position.x > GameState.middleroom -1 and position.x < GameState.middleroom +1):
		$AnimationPlayer.play("IDLE")
		velocity.x = 0
		deathtime += 1
		
	if deathtime == 110:
		$AnimationPlayer.play("JUMP")
		if in_water == true:
			velocity.y = WATER_JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY
	
	if deathtime > 120 and deathtime < 150:
		applyGrav(delta)
		if in_water == true:
			deathtime += 2
	
	if deathtime == 150 or deathtime == 190  or deathtime == 230 or deathtime == 270:
		velocity.y = 0
		ShieldProjectileAttack("res://scenes/objects/players/bossdataball.tscn", 8, 0, Vector2(900, 900))
		
	if deathtime == 170 or deathtime == 210  or deathtime == 250 or deathtime == 290:
		$Audio/Absorb.play()
		
		
	if deathtime == 350:
		$AnimationPlayer.play("VICTORYJUMP")
		GameState.current_weapon = GameState.stage_boss_weapon
		set_current_weapon_palette()
		$Audio/Cool.play()
		
	if deathtime == 380:
		$AnimationPlayer.play("FALL")
		
	if deathtime > 382 and deathtime < 700:
		applyGrav(delta)
		if is_on_floor():
			deathtime = 719
		
	if deathtime == 720:
		$AnimationPlayer.play("VICTORY_TELEPORT")
		$Audio/Warp.play()
		
	if deathtime == 735:
		velocity.y = -320
		$mainCollision.disabled = true
		
	if deathtime == 780:
		end_level()
