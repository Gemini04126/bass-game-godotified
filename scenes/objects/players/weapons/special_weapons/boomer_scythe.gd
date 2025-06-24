extends CharacterBody2D

const W_Type = GameState.DMGTYPE.CB_REAPER_1
var broken : bool
var direction : int
var state : int

@onready var state_timer = $Timer

func _ready():
	$SpawnSound.play()
	state_timer.start(0.35)
	state = 1
		
func _physics_process(_delta):
	if GameState.current_weapon != GameState.WEAPONS.REAPER:
		GameState.onscreen_sp_bullets -= 1
		queue_free()
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if state_timer.is_stopped() && state == 1:
		velocity.x = -velocity.x * 0.55
		velocity.y = -direction * 340
		state += 1
		state_timer.start(0.1)
		
	if state_timer.is_stopped() && state >= 2 && state < 6:
		velocity.x *= 1.08
		velocity.y *= 0.7
		state += 1
		state_timer.start(0.05)

	if state >= 3:
		velocity.x *= 0.85
		velocity.y *= 0.85
		position.x = move_toward(position.x, GameState.player.position.x, state * 0.6)
		position.y = move_toward(position.y, GameState.player.position.y, state * 0.4)
		
	
	if state_timer.is_stopped() && state >= 8:
		state += 1
		state_timer.start(0.1)
	
	if position.y > GameState.camposy + 108:
		position.y = GameState.camposy + 108
	if position.y < GameState.camposy - 108:
		position.y = GameState.camposy - 108
		
	if broken == true && state < 12:
		state = 12
		
	if move_and_slide() == true:
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets -= 1
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	GameState.onscreen_sp_bullets -= 1
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func kill():
	pass

func reflect():
	$CollisionShape2D.set_deferred("disabled", true)
	$ReflectSound.play()
	$AnimatedSprite2D.set_frame_and_progress(0, 0)
	if velocity.x < 0:
		velocity.x = 20
	if velocity.x > 0:
		velocity.x = -20
	velocity.y = -90
	broken = true
	


func _on_play_check_body_entered(body):
	if body.is_in_group("player"):
		GameState.onscreen_sp_bullets -= 1
		queue_free()
