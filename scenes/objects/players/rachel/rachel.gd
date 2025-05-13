extends MaestroPlayer

# Enums
enum WEAPONS {BUSTER, GALAXY, TOP, GEMINI, GRENADE, YAMATO, MAGMA, PHARAOH, CHILL, WIRE, BALLOON, MAGNET, TERRA, MERCURY, MARS, PLUTO, ROSE}

# References
@onready var rapid_timer = $Timers/RapidTimer

func _init() -> void:
	weapon_palette = [
		preload("res://sprites/players/rachel/palettes/Rachel Buster.png"),
		preload("res://sprites/players/rachel/palettes/Black Hole Bomb.png"),
		preload("res://sprites/players/rachel/palettes/Top Spin.png"),
		preload("res://sprites/players/rachel/palettes/Gemini Laser.png"),
		preload("res://sprites/players/rachel/palettes/Flash Bomb.png"),
		preload("res://sprites/players/rachel/palettes/Yamato Spear.png"),
		preload("res://sprites/players/rachel/palettes/Magma Bazooka.png"),
		preload("res://sprites/players/rachel/palettes/Pharaoh Wave.png"),
		preload("res://sprites/players/rachel/palettes/Chill Spike.png"),
		preload("res://sprites/players/rachel/palettes/Adaptors.png"),
		preload("res://sprites/players/rachel/palettes/Adaptors.png"),
		preload("res://sprites/players/rachel/palettes/Magnet Beam.png"),
		preload("res://sprites/players/rachel/palettes/Spark Chaser.png"),
		preload("res://sprites/players/rachel/palettes/Grab Buster.png"),
		preload("res://sprites/players/rachel/palettes/Photon Missile.png"),
		preload("res://sprites/players/rachel/palettes/Break Dash.png"),
		preload("res://sprites/players/rachel/palettes/Piko Hammer.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX1.png"),
		preload("res://sprites/players/copy_robot/palettes/ChargeX2.png"),
		preload("res://sprites/players/rachel/palettes/BreakCharge0.png"),
		preload("res://sprites/players/rachel/palettes/BreakCharge1.png")
	]

	projectile_scenes = [
		preload("res://scenes/objects/players/rachel/weapons/buster.tscn"),
		preload("res://scenes/objects/players/rachel/weapons/balloon_adaptor.tscn")
	]

	weapon_scenes = [
		preload("res://scenes/objects/players/rachel/weapons/pharaoh_wave.tscn")
	]

#region Weapon Shit
func processBuster():
	if Input.is_action_pressed("buster"):
		busterAnimMatch()
		weapon_buster()
		
func processShoot():
	if !transing && GameState.inputdisabled == false:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.BUSTER:
				if Input.is_action_pressed("shoot"): # add the rapid-fire thing here
					busterAnimMatch()
					weapon_buster()
			WEAPONS.GALAXY:
				if Input.is_action_just_pressed("shoot"):
					#the animation match stuff is within the actual weapon since its a two parter
					weapon_galaxy()
			WEAPONS.TOP:
				if Input.is_action_just_pressed("shoot"):
					#the animation match stuff is within the actual weapon since its a special state
					weapon_top()
			WEAPONS.GEMINI:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_gemini()
			WEAPONS.GRENADE:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_grenade()
			WEAPONS.YAMATO:
				if Input.is_action_pressed("shoot"):
					busterAnimMatch()
					weapon_yamato()
			WEAPONS.MAGMA:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_magma()
			WEAPONS.PHARAOH:
				if Input.is_action_just_pressed("shoot"):
					throwAnimMatch()
					weapon_pharaoh()
			WEAPONS.CHILL:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_chill()
			WEAPONS.WIRE:
				if Input.is_action_just_pressed("shoot"):
					#the animation match stuff is within the actual weapon since its a special state
					weapon_wire()
			WEAPONS.BALLOON:
				if Input.is_action_just_pressed("shoot"):
					throwAnimMatch()
					weapon_balloon()
			WEAPONS.MAGNET:
				if Input.is_action_pressed("shoot"):
					busterAnimMatch()
					weapon_magnet()
			WEAPONS.TERRA:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_terra()
			WEAPONS.MERCURY:
				if Input.is_action_just_pressed("shoot"):
					busterAnimMatch()
					weapon_mercury()
			WEAPONS.MARS:
				if Input.is_action_pressed("shoot"):
					busterAnimMatch()
					weapon_mars()
			WEAPONS.PLUTO:
				if Input.is_action_pressed("shoot"):
					#the animation match stuff is within the actual weapon since its a special state AND a two-parter
					weapon_pluto()
			WEAPONS.ROSE:
				if Input.is_action_just_pressed("shoot"):
					# holy shit this one's gonna be complex
					weapon_rose()

# ================
# WEAPON FUNCTIONS
# ================

## Rachel Buster
## Your default weapon. Deals 2 damage per hit?
##
func weapon_buster():
	if rapid_timer.is_stopped() and GameState.onscreen_bullets < 4:
		rapid_timer.start(0.15)
		shot_type = 0
		attack_timer.start(0.3)
		GameState.onscreen_bullets += 1
		projectile = projectile_scenes[0].instantiate()
		add_sibling(projectile)
		projectile.process_mode = Node.PROCESS_MODE_ALWAYS
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y + 4
		projectile.velocity.x = sprite.scale.x * 350
		projectile.scale.x = sprite.scale.x
		Charge = 0
		$Audio/Buster1.play()

## Black Hole Bomb
## Uses 4 WE, and deals 1 damage per hit.
## Fires a black hole that, when the button is pressed again, expands and starts to suck in projectiles and enemies. Multi-hits very frequently.
func weapon_galaxy():
	return

## Top Spin
## Uses 1 WE per hit, and deals 3 damage per hit.
## Makes its user spin rapidly, gives them full immunity to all enemies and attacks during its use, and allows them to bounce off enemies from the top.
func weapon_top():
	return

## Gemini Laser
## Uses 2 WE, and each segment deals 1 damage.
## Fires a 3-segment laser that bounces off of surfaces for a while, until eventually going offscreen on its own.
func weapon_gemini():
	return

## Flash Bomb
## Uses 1.12 WE, and deals 0.5 damage each time it hits, up to a total of 15 damage. 0.5 damage/0.05 seconds.
## Fires a bomb that explodes on contact with anything, dealing rapidly-hitting radius damage and lingering for 1.5 seconds.
func weapon_grenade():
	return

## Yamato Spear
## Uses 1 WE, and deals 2 damage.
## Fires a piercing projectile that either moves up or down depending on which direction it went last.
func weapon_yamato():
	return

## Magma Bazooka
## Uncharged: Fires three small shots in a spread pattern. Uses 0.5 WE, and deals 1 damage.
## Charged: Fires three large shots in a spread pattern. Uses 3 WE, and deals 3 damage.
func weapon_magma():
	return

## Pharaoh Wave
## Uses 1.75 WE, and deals ? damage.
## Fires two waves, one on each side of the user, that pierce armor and shields.
func weapon_pharaoh():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && GameState.weapon_energy[WEAPONS.PHARAOH] >= 1.75:
		if GameState.onscreen_sp_bullets == 0:
			GameState.weapon_energy[WEAPONS.PHARAOH] -= 1.75
			GameState.onscreen_sp_bullets += 2
			projectile = weapon_scenes[0].instantiate()
			add_sibling(projectile)
			projectile.position.x = position.x + 5
			projectile.position.y = position.y
			projectile.velocity.x = 200
			projectile.scale.x = 1

			projectile = weapon_scenes[0].instantiate()
			add_sibling(projectile)
			projectile.position.x = position.x - 5
			projectile.position.y = position.y
			projectile.velocity.x = -200
			projectile.scale.x = -1
			return

## Chill Spike
## Uses 1 WE. Glob deals 1 damage and freezes the enemy it hit, and spikes deal 2 damage.
## Fires a glob of an instantly-freezing material in an arc. Creates ice spikes when it hits a wall or floor, which break on contact or after a little bit of inactivity.
func weapon_chill():
	return

## Wire Adaptor
## Uses 2 WE, and can deal 1 damage if an enemy is hit by the hook on its way up.
## Fires a grappling hook at the ceiling that pulls you to itself (with 5 pixels between the top of the hook sprite and yourself).
func weapon_wire():
	return

## Balloon Adaptor
## Uses 2 WE, and deals no damage.
## Creates a balloon platform in front of you that slowly rises up and squishes when you stand on it.
func weapon_balloon():
	if Input.is_action_just_pressed("shoot") && (GameState.infinite_ammo || GameState.weapon_energy[WEAPONS.BALLOON] >= 2) && GameState.onscreen_sp_bullets < 3:
		anim.seek(0)
		if !GameState.infinite_ammo:
			GameState.weapon_energy[WEAPONS.BALLOON] -= 2
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[1].instantiate()
		add_sibling(projectile)

		projectile.position.y = position.y
		projectile.position.x = position.x + sprite.scale.x * 30

## Magnet Beam
## Uses 2 WE, no matter how long the platform is, and deals no damage.
## A tool that creates a temporary platform of varying length depending on how long you hold the button.
func weapon_magnet():
	return

## Spark Chaser
## Deals 1 damage per hit, uses 2 WE.
## Multi-hitting weapon that stops to dart back and forth between enemies.
func weapon_terra():
	return

## Grab Buster
## Uses 1 WE, and deals 1 damage.
## Fires a shot that heals you for 2HP if it hits.
func weapon_mercury():
	return

# G: okay, so the Megaman wiki was being really stupid about this one and had conflicting information, so I made up my own numbers
## Photon Missile
## Uses 2 WE, and deals 3 damage in a radius.
## Fires a missile with a delayed launch that can be repositioned if the button is held.
func weapon_mars():
	return

# G: I'm not finishing this right now... My power's about to go out and my computer's starting to lag out. <bop_it>I'm goin' ta' sleep.</bop_it>
## Break Dash
## Uncharged: Fires a standard Buster shot. Uses 0 WE, and deals 1 damage...?
## Charged: Dashes forward for a while and deals contact damage, while invincible to enemy attacks. Uses 2 WE, and deals 4 damage.
func weapon_pluto():
	if Input.is_action_just_released("shoot"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT):
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			if ScytheCharge < 33: #Uncharged. Buster shot, that's it
				weapon_buster()

			if ScytheCharge >= 33: # Dash forward
				pass

			ScytheCharge = 0

	if !Input.is_action_pressed("shoot"):
		ScytheCharge = 0

	if ScytheCharge >= 33 && GameState.weapon_energy[WEAPONS.PLUTO] < 2:
		ScytheCharge = 1

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[WEAPONS.PLUTO] > 0 or GameState.infinite_ammo == true):
		if ScytheCharge < 75:
			ScytheCharge += 1
			if ScytheCharge == 13:
				$Audio/Charge1.play()
			if ScytheCharge == 33:
				$Audio/Charge1.stop()
				$Audio/Charge2.play()
		else:
			ScytheCharge = 72
	else:
		Charge = 0
		$Audio/Charge1.stop()
		$Audio/Charge2.stop()
		return

## Piko Hammer
## Uses ? WE, and deals ? damage.
## A melee weapon that bounces you off of enemies when hit from above.
func weapon_rose():
	return
	
func processCharge():
	if weaponflashtimer < 2:
		weaponflashtimer += 1
	else:
		weaponflashtimer = 0
	
	if currentWeapon == WEAPONS.PLUTO:
		if ScytheCharge > 32:
			if weaponflashtimer == 1:
				sprite.material.set_shader_parameter("palette", weapon_palette[19])
			if weaponflashtimer != 1:
				set_current_weapon_palette()
		if ScytheCharge > 92:
			if weaponflashtimer == 2:
				sprite.material.set_shader_parameter("palette", weapon_palette[20])
		if ScytheCharge == 0:
			set_current_weapon_palette()
	
	if Input.is_action_pressed("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.PLUTO:
				weapon_pluto()
	elif Input.is_action_just_released("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.PLUTO:
				throwAnimMatch()
				weapon_pluto()

#endregion
