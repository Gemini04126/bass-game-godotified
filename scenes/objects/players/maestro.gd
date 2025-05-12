extends CharacterBody2D

class_name MaestroPlayer

#region Signals
signal teleported
#endregion

#region Enums
enum STATES {
	NONE, 
	TELEPORT, ##Teleporting down in a beam of energy
	TELEPORT_LANDING,
	IDLE,
	STEP,
	WALK,
	SLIDE,
	JUMP,
	FALL_START,
	FALL,
	FALL_SHOOT,
	LADDER,
	HURT,
	IDLE_SHOOT,
	WALKING_SHOOT,
	LADDER_SHOOT,
	JUMP_SHOOT,
	IDLE_THROW,
	JUMP_THROW,
	FALL_THROW,
	IDLE_SHIELD,
	JUMP_SHIELD,
	FALL_SHIELD,
	DEAD,
	DASH,
	IDLE_AIM,
	IDLE_AIM_DOWN,
	IDLE_AIM_DIAG,
	IDLE_AIM_UP,
	JUMP_AIM,
	JUMP_AIM_DOWN,
	JUMP_AIM_DIAG,
	JUMP_AIM_UP,
	FALL_AIM,
	FALL_AIM_DOWN,
	FALL_AIM_DIAG,
	FALL_AIM_UP,
	AIR_DASH,
	PAPER_CUT,
	IDLE_FIN_SHREDDER,
	IDLE_DOUBLE_FIN_SHREDDER,
	JUMP_FIN_SHREDDER,
	JUMP_DOUBLE_FIN_SHREDDER,
	FALL_FIN_SHREDDER,
	WARPING, #Using a teleporter
	WARP2 #Leaving a teleporter
}

enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}

#endregion

# state related
var invincible = false
var warping : int = 0
var standing
var currentState := STATES.TELEPORT
var currentWeapon : int = WEAPONS.BUSTER
var swapState := STATES.NONE
var numberOfTimesToRunStates := 0
var isFirstFrameOfState := false
var targetpos : float
var currentSpeed := 0
var fallstored : float
var slowed : bool
var direction
var canLadder : bool
var ladderArea
var underRoof : bool
var weaponflashtimer : int = 0
var dashdir : float # technically only ever uses ints but godot complains anyway
var dashjumped = false
var slideused = false
#input related


#region Exports
# input related
@export var JUMP_VELOCITY: int = -235
@export var PEAK_VELOCITY: int = -120
@export var STOP_VELOCITY: int = -120
@export var JUMP_HEIGHT: int = 14
@export var FAST_FALL: int = 400
@export var WATER_FAST_FALL: int = 200
@export var MAXSPEED: int = 100
@export var RUNSPEED: int = 80

@export var ICE_FLOOR_WEIGHT: float = 3
@export var ICE_AIR_WEIGHT: float = 1
#endregion

var transing : bool = false

#consts
const EXPLOSION_SPEEDS : Array[Vector2] = [ #G: Hey look, I can actually pretty much just copy what I had for the Genesis version...
# G (but from the Genesis): okay this kind of makes no sense but it also works to help visualize the orbs
								Vector2(0, -150),
		Vector2(-100, -100),						Vector2(100, -100),
								Vector2(0, -50),
	Vector2(-150, 0),	Vector2(-50, 0),	Vector2(50, 0),	Vector2(150, 0),
								Vector2(0, 50),
		Vector2(-100, 100),							Vector2(100, 100),
								Vector2(0, 150)
]
# weapon constants
const ORIGAMI_SPEED := 350
const CRACKER_SPEED := 450

#region References
#@onready var top_ladder_check: RayCast2D = $LadderCheck1
#@onready var bottom_ladder_check: RayCast2D = $LadderCheck2
#@onready var floor_ladder_check: RayCast2D = $LadderCheck3
@onready var state_timer: Timer = $Timers/StateTimer
@onready var invul_timer: Timer = $Timers/InvulTimer
@onready var pain_timer: Timer = $Timers/PainTimer
@onready var slide_timer: Timer = $Timers/SlideTimer
@onready var attack_timer: Timer = $Timers/FireDelay
@onready var death_timer: Timer = $Timers/DeathTimer
@onready var shoot_timer = $Timers/ShootTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var starburst: AnimatedSprite2D = $FX/Starburst
@onready var sweat: AnimatedSprite2D = $FX/Sweat
@onready var FX: Node2D
@onready var hurtbox = $hurtboxArea
@onready var projectile
@onready var shield
@onready var shield2
@onready var shield3
@onready var shield4
#endregion

#other vars
var DmgQueue : int # make the game not crash when you touch an enemy
var JumpHeight : int #How long you're holding the jump button to go higher
var StepTime : int #How long you're stepping
var PainTimer : int
var InvincFrames : int
var Charge : int
var ScytheCharge : int
var Flash_Timer : int
var progress : float
var no_grounded_movement : bool
var in_water : bool
var on_ice : bool
var ice_jump : bool
var wind_push = 0
var fall_timer: int

#Attack vars
var shot_type = 0

var weapon_palette: Array[Texture2D] = [
	preload("res://sprites/players/maestro/palettes/Maestro Buster.png"),
	preload("res://sprites/players/maestro/palettes/Scorch Barrier.png"),
	preload("res://sprites/players/maestro/palettes/Track 2.png"),
	preload("res://sprites/players/maestro/palettes/Poison Cloud.png"),
	preload("res://sprites/players/maestro/palettes/Fin Shredder.png"),
	preload("res://sprites/players/maestro/palettes/Origami Star.png"),
	preload("res://sprites/players/maestro/palettes/Wild Gale.png"),
	preload("res://sprites/players/maestro/palettes/Rolling Bomb.png"),
	preload("res://sprites/players/maestro/palettes/Boomerang Scythe.png"),
	preload("res://sprites/players/maestro/palettes/Maestro Buster.png"), # Proto Shield
	preload("res://sprites/players/maestro/palettes/Treble.png"), # "Treble Boost" (skip it)
	preload("res://sprites/players/maestro/palettes/Carry.png"),
	preload("res://sprites/players/maestro/palettes/Super Arrow.png"),
	preload("res://sprites/players/maestro/palettes/Mirror Buster.png"),
	preload("res://sprites/players/maestro/palettes/Screw Crusher.png"),
	preload("res://sprites/players/maestro/palettes/Ballade Cracker.png"),
	preload("res://sprites/players/maestro/palettes/Sakugarne.png"),
	preload("res://sprites/players/maestro/palettes/ChargeX1.png"),
	preload("res://sprites/players/maestro/palettes/ChargeX2.png"),
	preload("res://sprites/players/weapons/ScytheCharge0.png"),
	preload("res://sprites/players/weapons/ScytheCharge1.png")
]

var projectile_scenes = [
	preload("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/buster_medium.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/buster_large.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/carry.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn"),
	preload("res://scenes/objects/players/weapons/copy_robot/arrow.tscn")
]

var weapon_scenes = [
	preload("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn"),
	preload("res://scenes/objects/players/weapons/special_weapons/wild_gale.tscn")
]

func _ready():
	GameState.player = self
	GameState.onscreen_bullets = 0
	GameState.onscreen_sp_bullets = 0
	GameState.onscreen_track2s = 0
	state_timer.start(0.5)
	invul_timer.start(0.01)
	currentState = STATES.TELEPORT
	position.y = targetpos
	print(GameState.current_hp)

#So basically what this new state machine does is that it organizes every state into a little chunk that'll execute the functions it's meant to each frame. This way you won't need to have the
#function that applies gravity need to specify to only apply it during certain states since it will only execute on the correct states. It's also just nicer to look at.

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
				teleporting()
			STATES.IDLE, STATES.IDLE_SHOOT:
				idle(delta)
				slideProcess()
				checkForFloor()
				processJump()
				processShoot()
				processBuster()
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
				processBuster()
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
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.JUMP, STATES.JUMP_SHOOT, STATES.JUMP_THROW, STATES.JUMP_SHIELD:
				Jump(delta)
				applyGrav(delta)
				allowLeftRight(delta)
				processShoot()
				processBuster()
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
				processCharge()
				processShoot()
				processBuster()
				processDamage()
			STATES.HURT:
				hurt()
				applyGrav(delta)
			STATES.DEAD:
				dead()
		if GameState.freezeframe == false:
			position.x += wind_push
		animationMatching()
		switchWeapons()
		if currentState != STATES.DEAD:
			move_and_slide()
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
	
	#region Character Things

func invul(arg):
	hurtbox.monitorable = arg

func applyGrav(delta):
	if !transing:
		if not is_on_floor():
			velocity += get_gravity() * delta
			if fallstored != 0:
				velocity.y = fallstored
				fallstored = 0
			if FAST_FALL < velocity.y:
				velocity.y = FAST_FALL
	else:
		if velocity.y != 0:
			fallstored = velocity.y
			velocity.y = 0

func teleporting():
	if (position.y >= targetpos) && currentState == STATES.TELEPORT:
		position.y = targetpos
		velocity.y = 0
		teleported.emit()
		$Audio/Warp.play()
		currentState = STATES.TELEPORT_LANDING
	elif currentState == STATES.TELEPORT:
		$mainCollision.disabled = true
		$slideCollision.disabled = true
		velocity.y = 275
	

func idle(delta):
	if direction.x != 0 and GameState.inputdisabled == false:
		if on_ice == false:
			position.x += direction.x
			velocity.x = 0
		StepTime = 0
		currentState = STATES.STEP
	if on_ice == true:
		velocity.x = lerpf(velocity.x, 0, delta * ICE_FLOOR_WEIGHT)
	else:
		velocity.x = 0

func step(_delta):
	StepTime += 1
	if direction.x == 0 or GameState.inputdisabled == true:
		currentState = STATES.IDLE
	else:
		sprite.scale.x = direction.x
	if StepTime > 4:
		currentState = STATES.WALK

func walk():
	if direction.x == 0 or GameState.inputdisabled == true:
		currentState = STATES.IDLE

func allowLeftRight(delta):
	if GameState.inputdisabled == false:
		if direction.x != 0:
			sprite.scale.x = direction.x
			if on_ice == true:
				if (sprite.scale.x != sign(direction.x)) and currentSpeed != 0:
					if is_on_floor() == true && on_ice == true:
						if velocity.x <= -MAXSPEED && velocity.x >= MAXSPEED:
							velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * ICE_FLOOR_WEIGHT)
					else:
						currentSpeed = MAXSPEED
				if is_on_floor() == true && on_ice == true:
					velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.25, delta * ICE_FLOOR_WEIGHT)
			elif is_on_floor() == false && ice_jump == true:
					velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.25, delta * ICE_AIR_WEIGHT)
			elif slowed == true:
				velocity.x = 50 * direction.x
				pass
				
			else:
				if dashjumped == true && !is_on_floor():
					if direction.x == dashdir:
						velocity.x = 200 * direction.x
					else:
						velocity.x = 70 * direction.x
				else:
					velocity.x = MAXSPEED * direction.x
				sprite.scale.x = direction.x
				#velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * 4)
				
		#else:
			#if on_ice == false:
				#velocity.x = 0
			#else:
				#velocity.x = lerpf(velocity.x, 0, delta * 2 * sprite.scale.x)
	
func checkForFloor():
	
	if !is_on_floor():
		currentState = STATES.JUMP
		$mainCollision.disabled = false
		$slideCollision.disabled = true
		
func processJump():
	if GameState.inputdisabled == false:
		if Input.is_action_just_pressed("jump") && direction.y != -1:
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

func processDamage():
	#Process the Invul Frames first!
	if !invul_timer.is_stopped() && !transing:
		invincible = true
		$hurtboxArea/mainHurtbox.set_disabled(true)
		$hurtboxArea/slideHurtbox.set_disabled(true)
		DmgQueue = 0
		InvincFrames += 1
		if InvincFrames >= 2:
			sprite.visible = false
		if InvincFrames == 3:
			InvincFrames = 0
			sprite.visible = true
	else:
		if invincible == true:
			$FX/Starburst.visible = false
			if currentState == STATES.SLIDE:
				$hurtboxArea/slideHurtbox.set_disabled(false)
			else:
				$hurtboxArea/mainHurtbox.set_disabled(false)
			invincible = false
			
		sprite.visible = true
		
	#If you're not invulnerable... eat shit!
	if DmgQueue > 0:
		GameState.current_hp -= DmgQueue
		invul_timer.start(1.55)
		pain_timer.start(0.55)
		if GameState.current_hp > 0:
			$FX/Starburst.visible = true
			$FX/Sweat.visible = true
			$FX/Sweat.play("active")
			currentState = STATES.HURT
			velocity.x = sprite.scale.x * -20
			if is_on_floor():
				velocity.y = -70
			else:
				velocity.y = -90
		else:
			currentState = STATES.DEAD
			
		DmgQueue = 0
		$Audio/Hurt.play()

func Jump(delta):
	if is_on_floor():
		ice_jump = false
		dashjumped = false
		if direction.x != 0 and GameState.inputdisabled == false:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
	
	if on_ice == true:
		ice_jump = true
	if GameState.inputdisabled == false:
		if (JumpHeight < JUMP_HEIGHT && Input.is_action_pressed("jump")):
			velocity.y = JUMP_VELOCITY
			JumpHeight += 1
	if (JumpHeight == JUMP_HEIGHT):
		JumpHeight = 80
		velocity.y = PEAK_VELOCITY
	if (Input.is_action_just_released("jump") and JumpHeight < JUMP_HEIGHT):
		JumpHeight = 80
		velocity.y = STOP_VELOCITY
	if direction.x == 0 :
		if ice_jump == false:
			velocity.x = 0
		else:
			velocity.x = lerpf(velocity.x, 0, delta * ICE_AIR_WEIGHT)
	if is_on_ceiling() and JumpHeight < JUMP_HEIGHT:
		JumpHeight = 80
		velocity.y = STOP_VELOCITY
	
	if velocity.y > 0:
		JumpHeight = 80
		if currentState == STATES.JUMP:
			$AnimationPlayer.play("FALL")
			


func ladderCheck():
	if !Input.is_action_pressed("jump"):
		if direction.y == 1 && $upLadder.is_colliding():
			ladderArea = $upLadder.get_collider()
			ladderArea.refreshCollis(true)
			currentState = STATES.LADDER
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x
		if direction.y == -1 && $downLadder.is_colliding():
			ladderArea = $downLadder.get_collider()
			ladderArea.refreshCollis(false)
			currentState = STATES.LADDER
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x

func ladder():
	if direction.y != 0:
		velocity.y = -MAXSPEED*direction.y
	else:
		velocity.y = 0
	if direction.y == 1 && $upLadder.is_colliding() == false:
		currentState = STATES.IDLE
		velocity.y = 0
	if direction.y == -1 && is_on_floor():
		velocity.y = 0
		currentState = STATES.IDLE
	if Input.is_action_just_pressed("jump") && is_on_floor() == false:
		velocity.y = 0
		currentState = STATES.JUMP


func _on_collision_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("touching ladder!")

func _on_collision_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("ladder"):
		print("not touching ladder...")

func slideProcess():
	if GameState.inputdisabled == false:
		if direction.y == -1 && Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("dash"):
			if !on_ice:
				if GameState.upgrades_enabled[8]:
					velocity.x = 300 * sprite.scale.x
				else:
					velocity.x = 200 * sprite.scale.x
			currentState = STATES.SLIDE
			$mainCollision.disabled = true
			$slideCollision.disabled = false
			$hurtboxArea/mainHurtbox.set_disabled(true)
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
	
func sliding(delta):
	velocity.y = 0
	if !on_ice:
		if GameState.upgrades_enabled[8]:
			velocity.x = 300 * sprite.scale.x
		else:
			velocity.x = 200 * sprite.scale.x
	else:
		if GameState.upgrades_enabled[8]:
			velocity.x = lerpf(velocity.x, sprite.scale.x * 375, delta * 4)
		else:
			velocity.x = lerpf(velocity.x, sprite.scale.x * 250, delta * 4)
	
	if direction.x != 0:
		if direction.x + sprite.scale.x == 0:
			if $ceilCheck.is_colliding():
				sprite.scale.x = direction.x
			else:
				slide_timer.start(0.001)
	
	if !is_on_floor() and GameState.ultimate == false:
		velocity.x = 0
		currentState = STATES.JUMP
	if Input.is_action_just_pressed("jump"):
		$mainCollision.disabled = true
		$slideCollision.disabled = false
		$hurtboxArea/mainHurtbox.set_disabled(true)
		
func _on_slide_timer_timeout() -> void:
	if $ceilCheck.is_colliding() and is_on_floor():
		print("keep sliding")
		slide_timer.start(0.1)
	else:
		$mainCollision.disabled = false
		$slideCollision.disabled = true
		$hurtboxArea/mainHurtbox.set_disabled(false)
		if !is_on_floor():
			pass
		if on_ice == false:
			velocity.x = 0
		if direction.x:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
		


func _on_water_check(area: Area2D) -> void:
	if area.is_in_group("splash") and velocity.y != 0:
		var splash = preload("res://scenes/objects/splash.tscn").instantiate()
		add_child(splash)
		splash.name = "splashie"
		splash.top_level = true
		splash.global_position = $waterCheck.global_position



func hurt():
	if pain_timer.is_stopped():
		invul(false)
		if is_on_floor():
			currentState = STATES.IDLE
		else:
			currentState = STATES.JUMP

func check_for_death():
	if GameState.current_hp <= 0 && currentState != STATES.DEAD:
		death_timer.start(10)
		currentState = STATES.DEAD

func dead():
	$hurtboxArea/mainHurtbox.set_disabled(true)
	$hurtboxArea/slideHurtbox.set_disabled(true)
	state_timer.start(5.00)
	velocity.y = 0
	velocity.x = 0
	if pain_timer.is_stopped():
		$Audio/Death.play()
		#scale = Vector2.ZERO
		$Sprite2D.visible = false
		for i in 12:
			projectile = preload("res://scenes/objects/explosion_player.tscn").instantiate()
			add_child(projectile)
			#projectile.position.x = position.x
			#projectile.position.y = position.y
			projectile.velocity = EXPLOSION_SPEEDS[i]
		pain_timer.start(2550)
	if death_timer.is_stopped():
		sprite.visible = false
		Fade.fade_out()
		#await Fade.fade_out().finished # G: Seems to not work
		GameState.player_lives -= 1
		#Reset the stage
		reset(false)
		get_tree().reload_current_scene()
#endregion

#STATES.keys()[currentState]

func stopTeleportingFuckingIdiot():
	currentState = STATES.IDLE

func animationMatching():
	if anim.current_animation != STATES.keys()[currentState] and (velocity.y <= 0 or !attack_timer.is_stopped()):
		anim.play(STATES.keys()[currentState])

func busterAnimMatch():
	shoot_timer.start()
	if currentState == STATES.IDLE or currentState == STATES.STEP:
		currentState = STATES.IDLE_SHOOT
	elif currentState == STATES.WALK: # G: TODO: this seems to not work atm? there's a visible reset
		var getFrame = anim.get_current_animation_position()
		currentState = STATES.WALKING_SHOOT
		anim.seek(getFrame)
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHOOT

func shieldAnimMatch():
	shoot_timer.start()
	if currentState != STATES.SLIDE and is_on_floor():
		velocity.x = 0
		currentState = STATES.IDLE_SHIELD
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHIELD

func throwAnimMatch():
	shoot_timer.start()
	if currentState != STATES.SLIDE and is_on_floor():
		velocity.x = 0
		currentState = STATES.IDLE_THROW
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_THROW

func _on_shoot_timer_timeout() -> void:
	if STATES.keys()[currentState].contains("IDLE"):
		currentState = STATES.IDLE
	elif STATES.keys()[currentState].contains("WALK"):
		var getFrame = anim.current_animation_position
		currentState = STATES.WALK
		anim.seek(getFrame)
	elif STATES.keys()[currentState].contains("JUMP"):
		currentState = STATES.JUMP

#region Weapon Shit
func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing && GameState.inputdisabled == false:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.BUSTER:
				busterAnimMatch()
				weapon_buster()
			WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			WEAPONS.VIDEO:
				shieldAnimMatch()
				weapon_video()
			WEAPONS.SMOG:
				busterAnimMatch()
				weapon_smog()
			WEAPONS.SHARK:
				#throwAnimMatch()
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
#i dunno where the purple goes

func processCharge():
	if weaponflashtimer < 2:
		weaponflashtimer += 1
	else:
		weaponflashtimer = 0
	
	if currentWeapon == WEAPONS.REAPER:
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
			WEAPONS.REAPER:
				weapon_reaper()
	elif Input.is_action_just_released("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			WEAPONS.REAPER:
				throwAnimMatch()
				weapon_reaper()

func processBuster():
	if Input.is_action_just_pressed("buster"):
		busterAnimMatch()
		weapon_buster()

func weapon_buster():
	if GameState.onscreen_bullets < 3:
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

func weapon_blaze():
	if Input.is_action_just_pressed("shoot") and !transing:
		var space : float = 1.570796
		if shield == null && shield2 == null && shield3 == null && shield4 == null && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
			shot_type = 3
			anim.seek(0)
			attack_timer.start(0.5)
			shieldAnimMatch()
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield = weapon_scenes[2].instantiate()
				add_sibling(shield)
				shield.theta = 0*space
				shield.position = position
				
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 3 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield2 = weapon_scenes[2].instantiate()
				add_sibling(shield2)
				shield2.theta = 1*space
				shield2.position = position
				
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 2 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield3 = weapon_scenes[2].instantiate()
				add_sibling(shield3)
				shield3.theta = 2*space
				shield3.position = position
				
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 4 or GameState.infinite_ammo == true:
				GameState.onscreen_sp_bullets += 1
				shield4 = weapon_scenes[2].instantiate()
				add_sibling(shield4)
				shield4.theta = 3*space
				shield4.position = position
				
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[WEAPONS.BLAZE] -= 4
			#print(get_children())
		else:
			if shield or shield2 or shield3 or shield4:
				throwAnimMatch()
				shot_type = 2
				anim.seek(0)
				attack_timer.start(0.3)
				if shield != null:
					shield.fired = true
					if sprite.scale.x == -1:
						shield.left = true
				if shield2 != null:
					shield2.fired = true
					if sprite.scale.x == -1:
						shield2.left = true
				if shield3 != null:
					shield3.fired = true
					if sprite.scale.x == -1:
						shield3.left = true
				if shield4 != null:
					shield4.fired = true
					if sprite.scale.x == -1:
						shield4.left = true
				shield = null
				shield2 = null
				shield3 = null
				shield4 = null

func weapon_video():
	if Input.is_action_just_pressed("shoot") and !transing and GameState.freezeframe == false:
		GameState.freezedelay = 4
	else:
		GameState.freezeframe = false


func weapon_smog():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 1:
		if !transing:
			anim.seek(0)
			shot_type = 1
			attack_timer.start(0.3)
			GameState.onscreen_sp_bullets += 1
			projectile = weapon_scenes[1].instantiate()
			add_sibling(projectile)

			projectile.position.x = position.x + sprite.scale.x * 15
			projectile.position.y = position.y + 4
			projectile.velocity.x = sprite.scale.x * 100
			projectile.scale.x = sprite.scale.x
			return

func weapon_shark():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && is_on_floor() && (GameState.weapon_energy[GameState.WEAPONS.SHARK] >= 5 or GameState.infinite_ammo == true):
		if !transing:
			if GameState.onscreen_sp_bullets < 1:
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 5
				shoot_timer.start()
				velocity.x = 0
				currentState = STATES.IDLE_FIN_SHREDDER
				anim.seek(0)
				shot_type = 4
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				projectile = weapon_scenes[4].instantiate()
				add_sibling(projectile)
	
				projectile.position.x = position.x + sprite.scale.x * 15
				projectile.position.y = position.y - 3
				projectile.velocity.x = sprite.scale.x * 65
				projectile.scale.x = sprite.scale.x
				return

func weapon_origami():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 5:
		if !transing:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 1
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			GameState.onscreen_sp_bullets += 3
			projectile = weapon_scenes[0].instantiate()
	
			#SHOOT FORWARD
			if !Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down"):
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y = -ORIGAMI_SPEED * 0.225
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  ORIGAMI_SPEED * 0.225
	
			if Input.is_action_pressed("move_up"):
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.5
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.225
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED *  0.225
				projectile.velocity.y =  -ORIGAMI_SPEED * 0.775
	
			if Input.is_action_pressed("move_down"):
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED *  0.225
				projectile.velocity.y =  ORIGAMI_SPEED * 0.775
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.5
				projectile.velocity.y =  ORIGAMI_SPEED * 0.5
	
				projectile = weapon_scenes[0].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 9)
				projectile.position.y = position.y + 2
				projectile.scale.x = -sprite.scale.x
				projectile.velocity.x = sprite.scale.x * ORIGAMI_SPEED * 0.775
				projectile.velocity.y =  ORIGAMI_SPEED * 0.225

			return

func weapon_gale():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.GALE] >= 7 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 1:
		if !transing:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.GALE] -= 7
			anim.seek(0)
			GameState.onscreen_sp_bullets = 1
			shot_type = 3
			attack_timer.start(0.5)
			projectile = weapon_scenes[7].instantiate()
			
			add_sibling(projectile)
			projectile.position.x = GameState.camposx + (-280 * sprite.scale.x) 
			projectile.position.y = GameState.camposy
			
			projectile.scale.x = sprite.scale.x
			projectile.velocity.x = sprite.scale.x
			
			return

func weapon_guerilla():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.GUERRILLA] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets <= 2:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.GUERRILLA] -= 3
		anim.seek(0)
		shot_type = 1
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = weapon_scenes[3].instantiate()
		add_sibling(projectile)
		projectile.velocity.x = sprite.scale.x * 80
		projectile.velocity.y = 80
		
		projectile.scale.x = sprite.scale.x
		projectile.direction = sprite.scale.x
		
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y + 4

func weapon_reaper():
	if Input.is_action_just_released("shoot"):
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 2 and (GameState.weapon_energy[GameState.WEAPONS.REAPER] > 0 or GameState.infinite_ammo == true):
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			if ScytheCharge < 20: #Uncharged. Throws 1 boomerang with an alternating curve

				projectile = weapon_scenes[5].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 15)
				projectile.position.y = position.y - 2
				projectile.velocity.x = sprite.scale.x * 170
				projectile.scale.x = -sprite.scale.x
				GameState.onscreen_sp_bullets += 1

				if Input.is_action_pressed("move_up"):
					projectile.direction = 1
				elif Input.is_action_pressed("move_down"):
					projectile.direction = -1
				else:
					if  GameState.onscreen_sp_bullets != 1:
						projectile.direction = -1
					else:
						projectile.direction = 1

				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 1

			if ScytheCharge >= 20 and ScytheCharge < 70:  #Mid charge. Throws 2 shots that curve back in opposite ways
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 2
				GameState.onscreen_sp_bullets += 2

				projectile = weapon_scenes[5].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y - 8
				projectile.velocity.x = sprite.scale.x * 210
				projectile.velocity.y = 35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = -1

				projectile = weapon_scenes[5].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y + 8
				projectile.velocity.x = sprite.scale.x * 210
				projectile.velocity.y = -35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = 1

			if ScytheCharge >= 70: #Full charge. Throws 2 shots that run to the top and bottom of the screen and return.
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 4
				GameState.onscreen_sp_bullets += 2

				projectile = weapon_scenes[6].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y + 8
				projectile.velocity.x = sprite.scale.x * 310
				projectile.velocity.y = 35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = -1

				projectile = weapon_scenes[6].instantiate()
				add_sibling(projectile)
				projectile.position.x = position.x + (sprite.scale.x * 21)
				projectile.position.y = position.y - 8
				projectile.velocity.x = sprite.scale.x * 310
				projectile.velocity.y = -35
				projectile.scale.x = -sprite.scale.x
				projectile.direction = 1

			ScytheCharge = 0

	if !Input.is_action_pressed("shoot"):
		ScytheCharge = 0

	if ScytheCharge >= 20 && GameState.weapon_energy[GameState.WEAPONS.REAPER] < 2:
		ScytheCharge = 1

	if ScytheCharge >= 70 && GameState.weapon_energy[GameState.WEAPONS.REAPER] < 4:
		ScytheCharge = 26

	if Input.is_action_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.REAPER] > 0 or GameState.infinite_ammo == true):
		if ScytheCharge < 75:
			ScytheCharge += 1
			if ScytheCharge == 13:
				$Audio/Charge1.play()
			if ScytheCharge == 71:
				$Audio/Charge1.stop()
				$Audio/Charge2.play()
		else:
			ScytheCharge = 72
	else:
		Charge = 0
		$Audio/Charge1.stop()
		$Audio/Charge2.stop()
		return

func weapon_carry():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.CARRY] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 3:
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[3].instantiate()

		#SHOOT FORWARD REGARDLESS
		add_sibling(projectile)
		if is_on_floor():
			projectile.position.y = position.y
			projectile.position.x = position.x + sprite.scale.x * 30
		else:
			projectile.position.y = position.y + 24
			projectile.position.x = position.x

func weapon_arrow():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.ARROW] >= 4 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.ARROW] -= 4
		anim.seek(0)
		shot_type = 1
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[6].instantiate()

		#SHOOT FORWARD REGARDLESS
		add_sibling(projectile)
		projectile.position.x = position.x + (sprite.scale.x * 18)
		projectile.position.y = position.y + 4
		projectile.velocity.x = sprite.scale.x * 0.001
		projectile.scale.x = sprite.scale.x

func weapon_punk():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.PUNK] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 4:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.PUNK] -= 1
		anim.seek(0)
		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[5].instantiate()
		projectile.scale.x = sprite.scale.x

		add_sibling(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y

		projectile.velocity.y = -450
		projectile.velocity.x = sprite.scale.x * 95
	return

func weapon_ballade():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.BALLADE] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.BALLADE] -= 3
		anim.seek(0)

		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		projectile = projectile_scenes[4].instantiate()

		add_sibling(projectile)
		projectile.position.x = position.x
		projectile.position.y = position.y

		projectile.velocity.y = 0
		projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 1

		if(Input.is_action_pressed("move_up")):
			projectile.velocity.y = -CRACKER_SPEED * 0.5
			projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 0.5

		if(Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
			projectile.velocity.y = -CRACKER_SPEED * 1
			projectile.velocity.x = 0

		if(Input.is_action_pressed("move_down")):
			projectile.velocity.y = CRACKER_SPEED * 0.5
			projectile.velocity.x = sprite.scale.x * CRACKER_SPEED * 0.5
			return

func weapon_quint():
	return

func switchWeapons():
	if Input.is_action_just_pressed("switch_right"):
			GameState.freezeframe = false
			if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
				GameState.old_weapon = GameState.current_weapon
				if (GameState.current_weapon == GameState.WEAPONS.QUINT):
					GameState.current_weapon = GameState.WEAPONS.BUSTER
				else:
					GameState.current_weapon += 1
					if (GameState.current_weapon != GameState.WEAPONS.BUSTER):
						while (GameState.weapons_unlocked[GameState.current_weapon] == false):
							if (GameState.current_weapon == GameState.WEAPONS.QUINT && GameState.weapons_unlocked[GameState.WEAPONS.QUINT] == false):
								GameState.current_weapon = GameState.WEAPONS.BUSTER
							else:
								GameState.current_weapon += 1
	if Input.is_action_just_pressed("switch_left"):
			GameState.freezeframe = false
			if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
				GameState.old_weapon = GameState.current_weapon
				if (GameState.current_weapon == GameState.WEAPONS.BUSTER):
					GameState.current_weapon = GameState.WEAPONS.QUINT
				else:
					GameState.current_weapon -= 1
				while (GameState.weapons_unlocked[GameState.current_weapon] == false):
					GameState.current_weapon -= 1
	if GameState.old_weapon != GameState.current_weapon:
		GameState.onscreen_sp_bullets = 0
		if !Input.is_action_just_pressed("start"):
			$Audio/Switch.play()
			$Timers/SwitchTimer.start(2)
			$WeaponIcon.visible = true
			$WeaponIcon.frame = GameState.current_weapon
			if (GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true and GameState.current_weapon == GameState.WEAPONS.BUSTER):
				$WeaponIcon.frame = 11
		
		GameState.old_weapon = GameState.current_weapon
		set_current_weapon_palette()
	if  (Input.is_action_just_pressed("switch_left") && Input.is_action_pressed("switch_right")) or (Input.is_action_pressed("switch_left") && Input.is_action_just_pressed("switch_right")):
		if (currentState != STATES.TELEPORT and currentState != STATES.DEAD):
			GameState.current_weapon = GameState.WEAPONS.BUSTER
			if GameState.old_weapon != GameState.current_weapon:
				GameState.onscreen_sp_bullets = 0
			set_current_weapon_palette()

func set_current_weapon_palette() -> void:
	sprite.material.set_shader_parameter("palette", weapon_palette[GameState.current_weapon])

#endregion

func reset(everything: bool) -> void:
	GameState.refill_health()
	GameState.current_weapon = GameState.WEAPONS.BUSTER # Reset current weapon
	GameState.bosses.clear() # You died or reset the level anyway, so why not just clear the bosses?
	if everything == true:
		GameState.refill_ammo()

#func ice_jump_move(direction, delta):
	##movement in state
	#if direction.x:
		#sprite.scale.x = sign(direction.x)
		#if (direction.x == -1 && velocity.x > 20) or (direction.x == 1 && velocity.x < -20):
			#velocity.x = lerpf(velocity.x, 0, delta * 7)
		#else:
			#if (direction.x == 1 && velocity.x < 30) or (direction.x == -1 && velocity.x > -30):
				#velocity.x = lerpf(direction.x * 50, 0, delta * 7)
	#else:
		#velocity.x = lerpf(velocity.x, 0, delta * 4)


func _on_switch_timer_timeout():
	$WeaponIcon.visible = false
