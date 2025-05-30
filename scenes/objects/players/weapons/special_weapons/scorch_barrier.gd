extends CharacterBody2D

const trailscn = preload("res://scenes/objects/players/weapons/special_weapons/scorch_barrier_trail.tscn")
var trail

var W_Type = GameState.DMGTYPE.BS_BLAZE
#const FOLLOW_SPEED = 4.0 # follow speed
var player
@onready var parent = get_parent().get_parent()

var baseposx : float
var baseposy : float

var theta : float # changed from int to float

var radius : int
var dist : float
var rotatedir : int

var durability : int = 6
var invul : int
var DmgQueue : int # make the game not crash when you touch an enemy
var speed : int

var freezeframed : bool = false #prevents crashing lol

var wet : bool
var fired : bool
var left : bool

func _ready():
	GameState.onscreen_sp_bullets += 1
	if GameState.character_selected == 2:
		W_Type = GameState.DMGTYPE.CR_BLAZE
	else:
		W_Type = GameState.DMGTYPE.BS_BLAZE
	baseposx = position.x
	baseposy = position.y
	$SpawnSound.play()
	animate()
	
		
func _physics_process(_delta):
	if durability < 1:
		$CollisionShape2D.set_deferred("disabled", true)
		velocity.x = 0
		velocity.y = 0
		GameState.onscreen_sp_bullets -= 1
		$MainSprite.play("hit")
		await $MainSprite.animation_finished
		GameState.player.shields.erase(self)
		queue_free()
	
	if GameState.current_weapon != GameState.WEAPONS.BLAZE:
		durability = 0
		
	if GameState.player != null:
		$MainSprite.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	
	if wet == false:
		if durability > 0:
			if GameState.character_selected == 2:
				W_Type = GameState.DMGTYPE.CR_BLAZE
			else:
				W_Type = GameState.DMGTYPE.BS_BLAZE
			if ($MainSprite.animation == "Wet"):
				if GameState.character_selected == 2:
					$MainSprite.play("Copy")
				else:
					$MainSprite.play("Bass")
	else:
		if durability > 0:
			W_Type = GameState.DMGTYPE.CR_BUSTER_1
			$MainSprite.play("Wet")
	
	if invul > 0:
		invul = invul - 1
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		$CollisionShape2D.set_deferred("disabled", false)
	
	
		
	
	if fired == true && GameState.character_selected != 2: # Bass version
		if rotatedir == 1:
			dist += 1
			if dist > 10 :
				dist += 0.5
			if dist > 20 :
				dist += 0.5
			if dist > 30 :
				dist += 0.5
		if rotatedir == -1:
			dist -= 1
			if dist < -10 :
				dist -= 0.5
			if dist < -20 :
				dist -= 0.5
			if dist < -30 :
				dist -= 0.5
				
	if fired == true && GameState.character_selected == 2: # Copy Robot version
		radius = radius + 2
		if radius > 30:
			radius = radius + 1
		if radius > 50:
			radius = radius + 1
		if radius > 70:
			radius = radius + 1
	
	if (GameState.character_selected == 2 and radius < 30) or (GameState.character_selected != 2 and radius < 25):
		radius = radius + 1
	
	if fired == false:
		baseposx = GameState.player.position.x
		baseposy = GameState.player.position.y
		rotatedir = GameState.player.sprite.scale.x
		
	if rad_to_deg(theta) > 360:
		theta -= deg_to_rad(360)
	
	if GameState.character_selected == 2:
		theta += rotatedir*(0.35 * (1 -(radius * 0.020)))
		
	else:
		theta += 0.175 * rotatedir	
	if wet == false:
		if $AmbientSound.finished:
			$AmbientSound.play()
	
	position.x = dist + baseposx + cos(theta)*radius
	position.y = baseposy + sin(theta)*radius
	
	if ($MainSprite.animation != "Wet"):
		if (durability > 2):
			trail = trailscn.instantiate()
			add_sibling(trail)
			trail.position = position
			trail.set_frame_and_progress(6-durability,0)
		
		if durability >= 3:
			if GameState.character_selected == 2:
				$MainSprite.play("Copy-Move")
			else:
				$MainSprite.play("Bass-Move")
		else:
			if GameState.character_selected == 2:
				$MainSprite.play("Copy-Move")
			else:
				$MainSprite.play("Bass-Move2")
			
			
	#20*cos(pitch), 0, 8*sin(-pitch)
	
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	if fired == true:
		GameState.player.shields.erase(self)
		queue_free()

func destroy():
	if invul == 0:
		$HitSound.play()
		
		if durability > 0:
			$CollisionShape2D.set_deferred("disabled", true)
			invul = 5

func kill():
	pass

func reflect():
	pass	# not reflectable
	
func animate():
	if GameState.character_selected == 2:
		$MainSprite.play("Copy")
	else:
		$MainSprite.play("Bass")
