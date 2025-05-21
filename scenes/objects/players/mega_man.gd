extends MaestroPlayer

class_name MegaManPlayer

# Variables
var recoil : int
var busterflashtimer : int
var sharkcharge : int
var bustercharge : int
var sakugarne : bool = false

func _init() -> void:
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
		preload("res://sprites/players/megaman/palettes/MegaBuster.png"),
		preload("res://sprites/players/megaman/palettes/MagmaWave.png"),
		preload("res://sprites/players/megaman/palettes/WreckingBall.png"),
		preload("res://sprites/players/megaman/palettes/VoltBarrier.png"),
		preload("res://sprites/players/megaman/palettes/TripleThorn.png"),
		preload("res://sprites/players/megaman/palettes/RockSlam.png"),
		preload("res://sprites/players/megaman/palettes/DrillDropper.png"),
		preload("res://sprites/players/megaman/palettes/PlasmaBlade.png"),
		preload("res://sprites/players/megaman/palettes/SuperNova.png"),
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # Proto Shield
		preload("res://sprites/players/copy_robot/palettes/Copy Buster.png"), # "Treble Boost" (skip it)
		preload("res://sprites/players/megaman/palettes/MegaBall.png"),
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
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
		preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
		preload("res://scenes/objects/players/weapons/copy_robot/cr_fin_shredder.tscn"),
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
	
	if recoil != 0:
		if recoil < 0:
			position.x -= 1
			recoil += 1
		if recoil > 0:
			position.x += 1
			recoil -= 1
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
					sprite.material.set_shader_parameter("palette", weapon_palette[23])
				teleporting()
			STATES.IDLE, STATES.IDLE_SHOOT:
				idle(delta)
				slideProcess()
				checkForFloor()
				processJump()
				processShoot()
				#processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.IDLE_THROW, STATES.IDLE_FIN_SHREDDER, STATES.IDLE_DOUBLE_FIN_SHREDDER:
				checkForFloor()
				processJump()
				processShoot()
				processCharge()
				processDamage()
			STATES.IDLE_SHIELD:
				checkForFloor()
				processShoot()
				processDamage()
				
			STATES.STEP:
				step(delta)
				checkForFloor()
				slideProcess()
				processJump()
				processShoot()
				#processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.WALK, STATES.WALKING_SHOOT:
				walk()
				slideProcess()
				checkForFloor()
				processJump()
				allowLeftRight(delta)
				processShoot()
				#processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD, STATES.JUMP_FIN_SHREDDER:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				if GameState.ultimate == true:
					slideProcess()
				#processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.SLIDE:
				sliding(delta)
				if !$ceilCheck.is_colliding():
					processJump()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.LADDER:
				ladder()
				#ladderAnimMatch()
				processCharge()
				processShoot()
				#processBuster()
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
		if is_on_floor():
			standing = true
		else:
			standing = false
		
func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing && GameState.inputdisabled == false:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
				#buster stuff doesn't go here now
			GameState.WEAPONS.VIDEO:
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
	if bustercharge > 92:
		if busterflashtimer == 2:
			sprite.material.set_shader_parameter("palette", weapon_palette[18])
		
	elif currentWeapon == GameState.WEAPONS.BLAZE:
		if sharkcharge > 0:
			if weaponflashtimer == 1:
				sprite.material.set_shader_parameter("palette", weapon_palette[21])
			if weaponflashtimer != 1:
				set_current_weapon_palette()
		if sharkcharge > 25:
			if weaponflashtimer == 2:
				sprite.material.set_shader_parameter("palette", weapon_palette[22])
		if sharkcharge == 0:
			set_current_weapon_palette()
	if currentWeapon == GameState.WEAPONS.REAPER:
		if ScytheCharge > 19:
			if weaponflashtimer == 1:
				sprite.material.set_shader_parameter("palette", weapon_palette[19])
			if weaponflashtimer != 1:
				set_current_weapon_palette()
		if ScytheCharge > 69:
			if weaponflashtimer == 2:
				sprite.material.set_shader_parameter("palette", weapon_palette[20])
		if ScytheCharge == 0:
			set_current_weapon_palette()
	
	if Input.is_action_pressed("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			GameState.WEAPONS.REAPER:
				weapon_reaper()
			GameState.WEAPONS.BLAZE:
				weapon_magma()
				
	elif Input.is_action_just_released("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			GameState.WEAPONS.REAPER:
				throwAnimMatch()
				weapon_reaper()
			GameState.WEAPONS.BLAZE:
				weapon_magma()
				
	if (Input.is_action_pressed("shoot") or Input.is_action_pressed("buster")) && !transing:
		currentWeapon = GameState.current_weapon
		if currentWeapon == GameState.WEAPONS.BUSTER or Input.is_action_pressed("buster"):
			weapon_cbuster()
	elif (Input.is_action_just_released("shoot") or Input.is_action_just_released("buster")) && !transing:
		currentWeapon = GameState.current_weapon
		if currentWeapon == GameState.WEAPONS.BUSTER or Input.is_action_just_released("buster"):
			if GameState.inputdisabled == false:
				busterAnimMatch()
			weapon_cbuster()

# ================
# WEAPON FUNCTIONS
# ================
func weapon_cbuster():
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_pressed("shoot")) or Input.is_action_just_pressed("buster"):
		if GameState.inputdisabled == false:
			if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3 or (GameState.upgrades_enabled[3] == true and GameState.onscreen_bullets < 5)):
				attack_timer.start(0.3)
				GameState.onscreen_bullets += 1
				if GameState.ultimate == false:
					projectile = projectile_scenes[0].instantiate()
					$Audio/Buster1.play()
				
				else:
					projectile = projectile_scenes[1].instantiate()
					$Audio/Buster2.play()
				
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 18)
				projectile.position.y = position.y + 2
				projectile.velocity.x = sprite.scale.x * 350
				projectile.scale.x = sprite.scale.x
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				busterAnimMatch()
				return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_just_released("shoot")) or Input.is_action_just_released("buster"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and (GameState.onscreen_bullets < 3 or (GameState.upgrades_enabled[3] == true and GameState.onscreen_bullets < 5)):
			if bustercharge < 32: # no Charge
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
			if bustercharge >= 32 and bustercharge < 92: # medium charge
				if GameState.inputdisabled == false:
					attack_timer.start(0.3)
					GameState.onscreen_bullets += 1
					if GameState.ultimate == false:
						projectile = projectile_scenes[1].instantiate()
						$Audio/Buster2.play()
					else:
						projectile = projectile_scenes[2].instantiate()
						$Audio/Buster3.play()
					add_sibling(projectile)
					
					if GameState.ultimate == true and direction.y != 0:
						projectile.velocity.x = sprite.scale.x * 280
						projectile.velocity.y = direction.y * -70
					else:
						projectile.velocity.x = sprite.scale.x * 350
						
					projectile.position.x = position.x + (sprite.scale.x * 18)
					projectile.position.y = position.y + 2
					projectile.scale.x = sprite.scale.x
				bustercharge = 0
				$ChargeFX.play("none")
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
			if bustercharge >= 92: # da big boi
				if GameState.inputdisabled == false:
					attack_timer.start(0.3)
				
					position.x -= sprite.scale.x * 2
				
					GameState.onscreen_bullets += 1
					
					
					if GameState.ultimate == false:
						projectile = projectile_scenes[2].instantiate()
						$Audio/Buster3.play()
					else:
						projectile = projectile_scenes[9].instantiate()
						$Audio/Buster3.play()
					add_sibling(projectile)
					projectile.position.x = position.x + (sprite.scale.x * 18)
					projectile.position.y = position.y + 2
					
					if GameState.upgrades_enabled[6] and direction.y != 0:
						projectile.velocity.x = sprite.scale.x * 280
						projectile.velocity.y = direction.y * -70
					else:
						projectile.velocity.x = sprite.scale.x * 350
					projectile.scale.x = sprite.scale.x
					
					projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
					add_sibling(projectile)
					projectile.position.x = position.x + (sprite.scale.x * 18)
					projectile.position.y = position.y + 2
					recoil = -sprite.scale.x * 4
					
				$ChargeFX.play("none")
				bustercharge = 0
				$Audio/Charge1.stop()
				$Audio/Charge2.stop()
				set_current_weapon_palette()
				return
	if (GameState.current_weapon == GameState.WEAPONS.BUSTER and Input.is_action_pressed("shoot")) or Input.is_action_pressed("buster"):
		if bustercharge < 111:
			if GameState.upgrades_enabled[7] and busterflashtimer == 2:
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
		
func weapon_magma():
	if Input.is_action_just_released("shoot"):
		print("released")
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.BLAZE] > 3 or GameState.infinite_ammo == true):
			if sharkcharge < 25: #Uncharged. Single Fin Shredder

				anim.seek(0)
				shot_type = 4
				GameState.onscreen_sp_bullets += 1
				projectile = preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn").instantiate()
				add_sibling(projectile)
				shoot_timer.start(0.65)
				velocity.x = 0
				currentState = STATES.IDLE_FIN_SHREDDER
				
				
				
				if !is_on_floor():
					projectile.position.x = position.x + sprite.scale.x * 25
				else:
					projectile.position.x = position.x + sprite.scale.x * 15
				
				projectile.position.y = position.y - 3
				
				if !is_on_floor():
					projectile.velocity.x = sprite.scale.x * 45
				else:
					projectile.velocity.x = sprite.scale.x * 1
				projectile.scale.x = sprite.scale.x
				
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.BLAZE] -= 3

			if sharkcharge > 25: #Charged. Double Fin Shredder!
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.BLAZE] -= 4
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

	if sharkcharge >= 25 && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] < 6 and GameState.infinite_ammo == false):
		sharkcharge = 2

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] > 0 or GameState.infinite_ammo == true):
		print("pressed")
		if sharkcharge < 78:
			sharkcharge += 1
			if sharkcharge == 26:
				$Audio/Charge1.play()
		else:
			sharkcharge = 77
	else:
		sharkcharge = 0
		$Audio/Charge1.stop()
		$Audio/Charge2.stop()
		set_current_weapon_palette()
		return
		
func weapon_shark():
	if Input.is_action_just_released("shoot"):
		print("released")
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1 and (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 3 or GameState.infinite_ammo == true):
			if sharkcharge < 25: #Uncharged. Single Fin Shredder

				anim.seek(0)
				shot_type = 4
				GameState.onscreen_sp_bullets += 1
				projectile = weapon_scenes[4].instantiate()
				add_sibling(projectile)
				shoot_timer.start(0.65)
				velocity.x = 0
				currentState = STATES.IDLE_FIN_SHREDDER
				
				
				
				if !is_on_floor():
					projectile.position.x = position.x + sprite.scale.x * 25
				else:
					projectile.position.x = position.x + sprite.scale.x * 15
				
				projectile.position.y = position.y - 3
				
				if !is_on_floor():
					projectile.velocity.x = sprite.scale.x * 45
				else:
					projectile.velocity.x = sprite.scale.x * 1
				projectile.scale.x = sprite.scale.x
				
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 3

			if sharkcharge > 25: #Charged. Double Fin Shredder!
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

	if sharkcharge >= 25 && (GameState.weapon_energy[GameState.WEAPONS.SHARK] < 6 and GameState.infinite_ammo == false):
		sharkcharge = 2

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.SHARK] > 0 or GameState.infinite_ammo == true):
		print("pressed")
		if sharkcharge < 78:
			sharkcharge += 1
			if sharkcharge == 26:
				$Audio/Charge1.play()
		else:
			sharkcharge = 77
	else:
		sharkcharge = 0
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
	elif currentState == STATES.IDLE_THROW:
		currentState = STATES.IDLE
