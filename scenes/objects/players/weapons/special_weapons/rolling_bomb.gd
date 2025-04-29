extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CB_GUERILLA

var state := STATES.SPAWNED
var checker: String 
var direction: int
var explosion = preload("res://scenes/objects/players/weapons/special_weapons/rolling_blast.tscn")
var surface
var attached : bool
var time = 0
var blasts = 16

enum DIRECTION {
	NONE, 
	FLOOR, 
	CLIMB, 
	CEILING, 
	LOWER
	}

enum STATES{
	SPAWNED,
	DIE,
	CRAWLING
}

var CurrentDir = DIRECTION.NONE

func _ready():
	direction = scale.x
	$SpawnSound.play()

func _physics_process(delta):
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.GUERRILLA:
		queue_free()
	match state:
		STATES.SPAWNED:
			spawn()
		STATES.DIE:
			blast()
	move_and_slide()
	
	

func spawn():
	time += 1
	
	if surface == null:
		if $Point/FrontEnd.is_colliding() or $Point/BackEnd.is_colliding():
			surface = 1
			$Point.rotation = 0
			
		if $Point/ClimbCorner.is_colliding() or $Point/ClimbCorner2.is_colliding():
			surface = 1
			$Point.rotation -= deg_to_rad(90)
	
	if surface == 1:
		velocity.x = direction * (cos($Point.rotation) * 125)
		velocity.y = sin($Point.rotation) * 125
		if !$Point/FrontEnd.is_colliding() and !$Point/BackEnd.is_colliding() and ($Point/TurnCorner.is_colliding() or $Point/TurnCorner2.is_colliding() or $Point/TurnCorner3.is_colliding()):
			$Point.rotation += deg_to_rad(90)
			
		if $Point/ClimbCorner.is_colliding():
			$Point.rotation -= deg_to_rad(90)
			
		if !$Point/FrontEnd.is_colliding() and !$Point/BackEnd.is_colliding() and !$Point/TurnCorner.is_colliding() and !$Point/TurnCorner2.is_colliding() and !$Point/TurnCorner3.is_colliding():
			velocity.x -= direction * sin($Point.rotation) * 125
			velocity.y += cos($Point.rotation) * 125
			
func blast():
	if $Timer.is_stopped():
		blasts -= 1
		$Timer.start(0.05)
		if blasts > 0:
			var exp = explosion.instantiate()
			add_child(exp)
		if blasts == -50:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()
	print("del bomb")

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	state = STATES.DIE
	velocity.x = 0
	velocity.y = 0
	GameState.onscreen_sp_bullets -= 1
	$AnimatedSprite2D.play("hit")
	

func kill():
	destroy()

func reflect():
	destroy()
