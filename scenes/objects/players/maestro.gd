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
	LADDER,
	HURT,
	IDLE_SHOOT,
	WALKING_SHOOT,
	LADDER_SHOOT,
	JUMP_SHOOT,
	IDLE_THROW,
	LADDER_THROW,
	JUMP_THROW,
	IDLE_SHIELD,
	LADDER_SHIELD,
	JUMP_SHIELD,
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
	LADDER_AIM,
	LADDER_AIM_DOWN,
	LADDER_AIM_DIAG,
	LADDER_AIM_UP,
	AIR_DASH,
	PAPER_CUT,
	IDLE_FIN_SHREDDER,
	IDLE_DOUBLE_FIN_SHREDDER,
	JUMP_FIN_SHREDDER,
	VICTORY,
	WARPING, #Using a teleporter
	WARP2 #Leaving a teleporter
}
#endregion

# state related
var invincible = false
var victorydemo : bool = false
var leaving : int = 0
var warping : int = 0
var standing
var currentState := STATES.TELEPORT
var currentWeapon : int = GameState.WEAPONS.BUSTER
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
var forcebeamed : bool = false
var deathtime : int = 0
var ladderticks : int = 0

var shields : Array[Node2D]
#input related


#region Exports
# input related
@export var JUMP_VELOCITY: int = -235
@export var PEAK_VELOCITY: int = -120
@export var STOP_VELOCITY: int = -120
@export var JUMP_HEIGHT: int = 14
@export var FAST_FALL: int = 400

@export var WATER_JUMP_VELOCITY: int = -285
@export var WATER_PEAK_VELOCITY: int = -110
@export var WATER_STOP_VELOCITY: int = -110
@export var WATER_JUMP_HEIGHT: int = 23
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
var fall_timer: int

var wind_push = 0
var fan_push = 0

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

var default_projectile_offset := Vector2(18, 4)

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
				animationMatching()
			STATES.IDLE, STATES.IDLE_SHOOT:
				idle(delta)
				animationMatching()
				slideProcess()
				checkForFloor()
				processJump()
				processShoot()
				processBuster()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.IDLE_THROW, STATES.IDLE_FIN_SHREDDER:
				checkForFloor()
				animationMatching()
				processJump()
				processShoot()
				processCharge()
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
				processBuster()
				processCharge()
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
				animationMatching()
				if !$ceilCheck.is_colliding():
					processJump()
				processCharge()
				ladderCheck()
				processDamage()
			STATES.LADDER:
				ladder()
				ladderInput()
				ladderAnimate()
				processCharge()
				processShoot()
				processBuster()
				processDamage()
			STATES.LADDER_SHOOT, STATES.LADDER_THROW, STATES.LADDER_SHIELD:
				velocity.y = 0
				velocity.x = 0
				ladderInput()
				processCharge()
				processShoot()
				processBuster()
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
			$AnimationPlayer.play("WARPING")
			currentState = STATES.WARPING
		elif currentState != STATES.WARP2 and warping == 2:
			$AnimationPlayer.play("WARP2")
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
			if WATER_FAST_FALL < velocity.y and in_water == true:
				velocity.y = WATER_FAST_FALL
				
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
		if currentState == STATES.IDLE_SHOOT:
			currentState = STATES.WALKING_SHOOT
		else:
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
		if currentState == STATES.WALKING_SHOOT:
			currentState = STATES.IDLE_SHOOT
		else:
			currentState = STATES.IDLE

func allowLeftRight(delta):
	if GameState.inputdisabled == false:
		if direction.x != 0:
			sprite.scale.x = direction.x
			if on_ice == true:
				if (sprite.scale.x != sign(direction.x)) and currentSpeed != 0:
					if is_on_floor() == true && on_ice == true:
						if velocity.x <= -MAXSPEED && velocity.x >= MAXSPEED:
							velocity.x = lerpf(velocity.x, sprite.scale.x * 350, delta * ICE_FLOOR_WEIGHT)
					else:
						currentSpeed = MAXSPEED
				if is_on_floor() == true && on_ice == true:
					velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.5, delta * ICE_FLOOR_WEIGHT)
			elif is_on_floor() == false && ice_jump == true:
					velocity.x = lerpf(velocity.x, sprite.scale.x * MAXSPEED * 1.5, delta * ICE_AIR_WEIGHT)
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
				if in_water == true:
					velocity.y = WATER_JUMP_VELOCITY
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
		$Audio/Land.play()
		if direction.x != 0 and GameState.inputdisabled == false:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
	if dashjumped == true and JumpHeight < 3:
		JumpHeight = 4
	if on_ice == true:
		ice_jump = true
	if GameState.inputdisabled == false:
		if (((in_water == false and JumpHeight < JUMP_HEIGHT) or (in_water == true and JumpHeight < WATER_JUMP_HEIGHT)) && Input.is_action_pressed("jump")):
			if in_water == true:
				velocity.y = WATER_JUMP_VELOCITY
			else:
				velocity.y = JUMP_VELOCITY
			JumpHeight += 1
			if fan_push < 0:
				JumpHeight += 2
	if (((in_water == false and JumpHeight == JUMP_HEIGHT) or (in_water == true and JumpHeight == WATER_JUMP_HEIGHT))):
		JumpHeight = 80
		if in_water == true:
			velocity.y = WATER_PEAK_VELOCITY
		else:
			velocity.y = PEAK_VELOCITY
	if (Input.is_action_just_released("jump") and ((in_water == false and JumpHeight < JUMP_HEIGHT) or (in_water == true and JumpHeight < WATER_JUMP_HEIGHT))):
		JumpHeight = 80
		if in_water == true:
			velocity.y = WATER_STOP_VELOCITY
		else:
			velocity.y = STOP_VELOCITY
	if direction.x == 0 :
		if ice_jump == false:
			velocity.x = 0
		else:
			velocity.x = lerpf(velocity.x, 0, delta * ICE_AIR_WEIGHT)
	if is_on_ceiling() and ((in_water == false and JumpHeight < JUMP_HEIGHT) or (in_water == true and JumpHeight < WATER_JUMP_HEIGHT)):
		JumpHeight = 80
		if in_water == true:
			velocity.y = WATER_STOP_VELOCITY
		else:
			velocity.y = STOP_VELOCITY
	
	if velocity.y > 0:
		JumpHeight = 80
		
	if currentState == STATES.JUMP and attack_timer.is_stopped():
		if (velocity.y > 0 and fan_push <= 0) or fan_push < 0:
			$AnimationPlayer.play("FALL")
		else:
			$AnimationPlayer.play("JUMP")
	else:
		animationMatching()
			


func ladderCheck():
	if !Input.is_action_pressed("jump"):
		if direction.y == 1 && $upLadder.is_colliding():
			ladderArea = $upLadder.get_collider()
			ladderArea.refreshCollis(true)
			currentState = STATES.LADDER
			$AnimationPlayer.play("LADDER-1-IDLE")
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x
		if direction.y == -1 && $downLadder.is_colliding():
			ladderArea = $downLadder.get_collider()
			ladderArea.refreshCollis(false)
			currentState = STATES.LADDER
			$AnimationPlayer.play("LADDER-1-IDLE")
			velocity.x = 0
			velocity.y = 0
			position.x = ladderArea.position.x

func ladder():
	anim.speed_scale = 1
	if direction.y != 0:
		velocity.y = -MAXSPEED*direction.y
		ladderticks += 1
	else:
		velocity.y = 0
	if direction.y == 1 && $upLadder.is_colliding() == false:
		currentState = STATES.IDLE
		velocity.y = 0
		
	if direction.y == -1 && is_on_floor():
		velocity.y = 0
		currentState = STATES.IDLE
		
func ladderInput():
	if Input.is_action_just_pressed("jump") && is_on_floor() == false:
		velocity.y = 0
		if currentState == STATES.LADDER_SHOOT or currentState == STATES.LADDER_AIM or currentState == STATES.LADDER_AIM_DOWN or currentState == STATES.LADDER_AIM_DIAG or currentState == STATES.LADDER_AIM_UP:
			currentState = STATES.JUMP_SHOOT
		elif currentState == STATES.LADDER_THROW:
			currentState = STATES.JUMP_THROW
		else:
			currentState = STATES.JUMP
	
	if Input.is_action_just_pressed("buster") or Input.is_action_just_pressed("shoot") and direction.x != 0:
		sprite.scale.x = direction.x
		
		
		
func ladderAnimate():
	if $topLadder.is_colliding():
		if $AnimationPlayer.current_animation == ("LADDER_UP"):
			$AnimationPlayer.play("LADDER-2")
		if ladderticks >= 18:
			if $AnimationPlayer.current_animation == ("LADDER-1-IDLE") or $AnimationPlayer.current_animation == ("LADDER-1"):
				$AnimationPlayer.play("LADDER-2")
			elif $AnimationPlayer.current_animation == ("LADDER-2-IDLE") or $AnimationPlayer.current_animation == ("LADDER-2"):
				$AnimationPlayer.play("LADDER-1")
			ladderticks = 0
	else:
		$AnimationPlayer.play("LADDER_UP")
		
		
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
				if GameState.upgrades_enabled[13]:
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
		if GameState.upgrades_enabled[13]:
			velocity.x = 300 * sprite.scale.x
		else:
			velocity.x = 200 * sprite.scale.x
	else:
		if GameState.upgrades_enabled[13]:
			velocity.x = lerpf(velocity.x, sprite.scale.x * 375, delta * 4)
		else:
			velocity.x = lerpf(velocity.x, sprite.scale.x * 300, delta * 4)
	
	if direction.x != 0:
		if direction.x + sprite.scale.x == 0:
			if $ceilCheck.is_colliding():
				sprite.scale.x = direction.x
			else:
				slide_timer.start(0.001)
	
	if !is_on_floor() and GameState.ultimate == false:
		if ice_jump == false:
			velocity.x = 0
		currentState = STATES.JUMP
		
	if Input.is_action_just_pressed("jump") and !$ceilCheck.is_colliding():
		$mainCollision.disabled = false
		$slideCollision.disabled = true
		$hurtboxArea/mainHurtbox.set_disabled(false)
		
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
		if on_ice == false and ice_jump == false:
			velocity.x = 0
		if direction.x:
			currentState = STATES.WALK
		else:
			currentState = STATES.IDLE
		


func _on_water_check(area: Area2D) -> void:
	if area.is_in_group("splash"):
		var splash = preload("res://scenes/objects/splash.tscn").instantiate()
		add_child.call_deferred(splash)
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
		death_timer.start()
		pain_timer.start(1.5)
		if !pain_timer.is_stopped() && !death_timer.is_stopped():
			currentState = STATES.DEAD

func dead():
	$hurtboxArea/mainHurtbox.set_disabled(true)
	$hurtboxArea/slideHurtbox.set_disabled(true)
	deathtime += 1
	velocity.y = 0
	velocity.x = 0
	if deathtime == 1:
		GameState.hit_stop = 20
		if GameState.continuous_music == false:
			GameState.music.stop()
	if deathtime == 10:
		$Audio/Death.play()
		sprite.visible = false
		for i in 12:
			projectile = preload("res://scenes/objects/explosion_player.tscn").instantiate()
			add_child(projectile)
			projectile.velocity = EXPLOSION_SPEEDS[i]
		pain_timer.start(2550)
	if deathtime == 160:
		print("death")
		Fade.fade_out()
	if deathtime == 200:
		GameState.player_lives -= 1
		if GameState.player_lives < 0:
			get_tree().change_scene_to_file("res://scenes/menus/continue.tscn")
			reset(false)
		else:
			reset(false)
			get_tree().reload_current_scene()


#STATES.keys()[currentState]

func stopTeleportingFuckingIdiot():
	currentState = STATES.IDLE

func animationMatching():
	if anim.current_animation != STATES.keys()[currentState]:
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
	elif currentState == STATES.LADDER:
		currentState = STATES.LADDER_SHOOT

func shieldAnimMatch():
	shoot_timer.start()
	if currentState != STATES.SLIDE and is_on_floor() and on_ice == false:
		velocity.x = 0
		currentState = STATES.IDLE_SHIELD
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_SHIELD
	elif currentState == STATES.LADDER:
		currentState = STATES.LADDER_THROW

func throwAnimMatch():
	shoot_timer.start()
	if currentState != STATES.SLIDE and is_on_floor() and on_ice == false:
		velocity.x = 0
		currentState = STATES.IDLE_THROW
	elif currentState == STATES.JUMP:
		currentState = STATES.JUMP_THROW
	elif currentState == STATES.LADDER:
		currentState = STATES.LADDER_THROW

func ladderAnimMatch():
	if $topLadder.is_colliding() == false:
		anim.play("LADDER_UP")
	else:
		anim.play("LADDER")

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
		$AnimationPlayer.play("LADDER-2-IDLE")
		currentState = STATES.LADDER

#region Weapon Shit
func processShoot():
	if Input.is_action_just_pressed("shoot") && !transing && GameState.inputdisabled == false:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			GameState.WEAPONS.BUSTER:
				busterAnimMatch()
				weapon_buster()
			GameState.WEAPONS.BLAZE:
				#the animation match stuff is within the actual weapon since its a two parter
				weapon_blaze()
			GameState.WEAPONS.VIDEO:
				shieldAnimMatch()
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
#i dunno where the purple goes

func processCharge():
	if weaponflashtimer < 2:
		weaponflashtimer += 1
	else:
		weaponflashtimer = 0
	
	if currentWeapon == GameState.WEAPONS.REAPER:
		$ScytheChargeFX.material.set_shader_parameter("palette", sprite.material.get_shader_parameter("palette"))
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
	elif Input.is_action_just_released("shoot") && !transing:
		currentWeapon = GameState.current_weapon
		match currentWeapon:
			GameState.WEAPONS.REAPER:
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
		BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/buster_small.tscn", Vector2(350, 0))
		Charge = 0
		$Audio/Buster1.play()

func weapon_blaze():
	if Input.is_action_just_pressed("shoot") and !transing:
		if shields.size() == 0 && (GameState.weapon_energy[GameState.WEAPONS.BLAZE] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
			shot_type = 3
			anim.seek(0)
			attack_timer.start(0.5)
			shieldAnimMatch()
			
			if GameState.weapon_energy[GameState.WEAPONS.BLAZE] < 4:
				ShieldProjectileAttack("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn", GameState.weapon_energy[GameState.WEAPONS.BLAZE], 0)
			else:
				ShieldProjectileAttack("res://scenes/objects/players/weapons/special_weapons/scorch_barrier.tscn", 4, 0)
			
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.BLAZE] -= 4
		else:
			if shields.size() > 0:
				throwAnimMatch()
				shot_type = 2
				anim.seek(0)
				attack_timer.start(0.3)
				for i in shields.size():
					shields[i].fired = true
				shields.clear()

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
			BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/poison_cloud.tscn", Vector2(75, 0))

func weapon_shark():
	if Input.is_action_just_pressed("shoot") && (currentState != STATES.SLIDE) and (currentState != STATES.HURT) && is_on_floor() && (GameState.weapon_energy[GameState.WEAPONS.SHARK] >= 5 or GameState.infinite_ammo == true):
		if !transing:
			if GameState.onscreen_sp_bullets < 1:
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 5
				shoot_timer.start()
				if on_ice == false:
					velocity.x = 0
				currentState = STATES.IDLE_FIN_SHREDDER
				anim.seek(0)
				shot_type = 4
				attack_timer.start(0.51)
				GameState.onscreen_sp_bullets += 1
				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/fin_shredder.tscn", Vector2(65, 0), Vector2(15, 0))

func weapon_origami():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] >= 1 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets < 5:
		if !transing:
			if GameState.infinite_ammo == false:
				GameState.weapon_energy[GameState.WEAPONS.ORIGAMI] -= 1
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			GameState.onscreen_sp_bullets += 3
			
			SpreadProjectileAttack("res://scenes/objects/players/weapons/special_weapons/origami_star.tscn",3,60,250,direction.y * -30)

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
		BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/rolling_bomb.tscn", Vector2(80, 80), Vector2(18, 4))

func weapon_reaper():
	if ScytheCharge == 0:
		$ScytheChargeFX.play("none")
	if ScytheCharge == 20:
		$ScytheChargeFX.play("charge1")
	if ScytheCharge == 70:
		$ScytheChargeFX.play("charge2")
	
	if Input.is_action_just_released("shoot"):
		$ScytheChargeFX.play("none")
		if (currentState != STATES.SLIDE) and (currentState != STATES.HURT) and GameState.onscreen_sp_bullets < 2 and (GameState.weapon_energy[GameState.WEAPONS.REAPER] > 0 or GameState.infinite_ammo == true):
			anim.seek(0)
			shot_type = 2
			attack_timer.start(0.3)
			if ScytheCharge < 20: #Uncharged. Throws 1 boomerang with an alternating curve
				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn", Vector2(340, 0), Vector2(15, -2))
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
				
				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn", Vector2(360, 65), Vector2(21, -8))
				projectile.direction = -1

				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/boomer_scythe.tscn", Vector2(360, -65), Vector2(21, 8))
				projectile.direction = 1

			if ScytheCharge >= 70: #Full charge. Throws 2 shots that run to the top and bottom of the screen and return.
				if GameState.infinite_ammo == false:
					GameState.weapon_energy[GameState.WEAPONS.REAPER] -= 4
				GameState.onscreen_sp_bullets += 2

				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn", Vector2(480, 35), Vector2(21, 8))
				projectile.direction = -1

				BasicProjectileAttack("res://scenes/objects/players/weapons/special_weapons/charge_scythe.tscn", Vector2(480, -35), Vector2(21, -8))
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
		BasicProjectileAttack("res://scenes/objects/players/weapons/copy_robot/screw_crusher.tscn", Vector2(95, -450),Vector2(10,0))
	return

func weapon_ballade():
	if Input.is_action_just_pressed("shoot") && (GameState.weapon_energy[GameState.WEAPONS.BALLADE] >= 3 or GameState.infinite_ammo == true) && GameState.onscreen_sp_bullets == 0:
		if GameState.infinite_ammo == false:
			GameState.weapon_energy[GameState.WEAPONS.BALLADE] -= 3
		throwAnimMatch()
		anim.seek(0)

		shot_type = 2
		attack_timer.start(0.3)
		GameState.onscreen_sp_bullets += 1
		AimProjectileAttack("res://scenes/objects/players/weapons/copy_robot/ballade_cracker.tscn", 350, true, Vector2(0,0))


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
		if Input.is_action_just_pressed("switch_left") or Input.is_action_just_pressed("switch_right"):
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
		
	if deathtime == 120:
		$AnimationPlayer.play("VICTORY_TELEPORT")
		$Audio/Warp.play()
		
	if deathtime == 135:
		velocity.y = -320
		$mainCollision.disabled = true

	if deathtime == 180:
		end_level()

## A basic projectile attack.
##
## scenePath: A String with the path to the desired scene.
## speed: A Vector2 containing the desired horizontal and vertical speed, without scale multipliers, as they are done automatically.
## offset: A Vector2 containing the desired offset, with the character's Buster offsets by default. Optional.
## projectileScale: A Vector2 containing a scale multiplier for the projectile. Useful for projectiles that need to be upside down or backwards or something. Optional.
func BasicProjectileAttack(scenePath: String, speed: Vector2, offset:= default_projectile_offset, projectileScale:= Vector2(1, 1)):
	projectile = load(scenePath).instantiate()
	add_sibling(projectile)
	projectile.process_mode = Node.PROCESS_MODE_ALWAYS
	projectile.position = position + (offset * (sprite.scale * projectileScale))
	projectile.velocity = speed * (sprite.scale * projectileScale)
	projectile.scale = (sprite.scale * projectileScale)
	if "direction" in projectile:
		projectile.direction = sprite.scale.x * projectileScale.x
		
## An aimable projectile attack.
##
## scenePath: A String with the path to the desired scene.
## speed: The speed at which the projectile moves. Automatically calculated 
## allowdown: Allow aiming directly down. If false, it will be diagonal down.
## offset: A Vector2 containing the desired offset, with the character's Buster offsets by default. Optional.
## projectileScale: A Vector2 containing a scale multiplier for the projectile. Useful for projectiles that need to be upside down or backwards or something. Optional.
func AimProjectileAttack(scenePath: String, speed: float, allowdown:bool, offset:= default_projectile_offset, projectileScale:= Vector2(1, 1)):
	BasicProjectileAttack(scenePath,Vector2(0,0),offset,projectileScale)
	if direction.y == -1 and allowdown == false:
		projectile.velocity.x = speed * (sprite.scale.x * 0.5)
		projectile.velocity.y = speed * (1 * 0.5)
	elif direction.x == 0 and direction.y == 0:
		projectile.velocity.x = speed * (sprite.scale.x)
	elif direction.x != 0 and direction.y != 0:
		projectile.velocity.x = speed * (direction.x * 0.5)
		projectile.velocity.y = speed * (-direction.y * 0.5)
	elif direction.x == 0 or direction.y == 0:
		projectile.velocity.x = speed * (direction.x)
		projectile.velocity.y = speed * (-direction.y)
	
## Summons a group of projectiles from the player, evenly divided.
## a var named theta must be required. That is the angle which the projectile is offset from the player.
## scenePath: A String with the path to the desired scene.
## amount : How many projectiles. They are spread evenly among 360 degrees. 
## initoffset: If you want the first projectile to spawn somewhere else, use this! in degrees
## offset: A Vector2 containing the desired offset, with the character's Buster offsets by default. Optional.
## projectileScale: A Vector2 containing a scale multiplier for the projectile. Useful for projectiles that need to be upside down or backwards or something. Optional.

func ShieldProjectileAttack(scenePath: String, amount : int, initoffset : int = 0, offset:= Vector2(0,0), projectileScale:= Vector2(1, 1)):
	var space = deg_to_rad(360/amount)
	var first = deg_to_rad(initoffset)
	var count = 0
			
	while count < amount:
		BasicProjectileAttack(scenePath,Vector2(0,0),offset,projectileScale)
		shields.append(projectile)
		projectile.theta = (count*space) + first
		count += 1

## Summons a group of projectiles from the player, evenly divided.
## a var named theta must be required. That is the angle which the projectile is offset from the player.
## scenePath: A String with the path to the desired scene.
## amount : How many projectiles. They are spread evenly among 360 degrees. 
## initoffset: If you want the first projectile to spawn somewhere else, use this! Optional
## offset: A Vector2 containing the desired offset, with the character's Buster offsets by default. Optional.
## projectileScale: A Vector2 containing a scale multiplier for the projectile. Useful for projectiles that need to be upside down or backwards or something. Optional.

func SpreadProjectileAttack(scenePath: String, amount : int, spread : float, speed : int, initoffset : int = 0, offset:= Vector2(0,0), projectileScale:= Vector2(1, 1)):
	var interval = deg_to_rad(spread/amount)
	var first = deg_to_rad(initoffset)
	var count = 0
	var angler : float
	
	if amount % 2 == 0:
		first += interval * -0.5
	
	angler = -((amount - 1) / 2) * interval + first 
	
	print(angler)

	
	while count < amount:
		BasicProjectileAttack(scenePath, Vector2(cos(angler)*speed,sin(angler)*speed), offset, projectileScale)
		angler += interval
		
		count += 1

func end_level() -> void:
	await Fade.fade_out().finished
	reset(true)
	if GameState.stage_action == 0:
		if GameState.stage_progress_update:
			GameState.PROGRESSDICT.set(GameState.stage_progress_update, true)
		get_tree().change_scene_to_file("res://scenes/menus/weapon_get.tscn")
	elif GameState.stage_action == 1:
		get_tree().change_scene_to_file("res://scenes/menus/stage_select.tscn")
	Fade.fade_in()
