extends CharacterBody2D

var projectile
var buster_timer : int
var timer : int
var flash_timer : int
var buster_speed = 300
var explode_state : int

var aim : int

# Change the animation with keeping the frame index and progress.
@onready var sprite = $AnimatedSprite2D
@onready var current_frame = sprite.get_frame()
@onready var current_progress = sprite.get_frame_progress()

func _ready():
	$SpawnSound.play()

func _physics_process(delta):
	timer += 2
	if timer <= 850:
		handle_buster()
	if timer > 850 && explode_state == 0:
		handle_buster()
		if $AnimatedSprite2D.animation != "explode":
			flash_timer += 1
			if flash_timer == 3:
				$AnimatedSprite2D.hide()
			if flash_timer == 6:
				$AnimatedSprite2D.show()
				flash_timer = 0
		else:
			$AnimatedSprite2D.show()
	if timer > 900:
		projectile = preload("res://scenes/objects/explosion_1.tscn").instantiate()
		get_parent().add_child(projectile)
		
		projectile.position = position
		die()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	die()

func die():
	GameState.onscreen_track2s -= 1
	print(GameState.onscreen_track2s)
	print("exploded")
	queue_free()

func handle_buster():
	buster_timer += 1
	current_frame = $AnimatedSprite2D.get_frame()
	current_progress = $AnimatedSprite2D.get_frame_progress()
	
	if (Input.is_action_pressed("buster") && Input.is_action_pressed("move_down")):
		$AnimatedSprite2D.play("Down")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		aim = -1
		

	if (Input.is_action_pressed("buster") && Input.is_action_pressed("move_up")):
		aim = 1
		$AnimatedSprite2D.play("Diag")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed("buster") && Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
		aim = 2
		$AnimatedSprite2D.play("Up")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed("buster") && !Input.is_action_pressed("move_down") && !Input.is_action_pressed("move_up") &&  (Input.is_action_pressed("move_left") or  Input.is_action_pressed("move_right"))):
		aim = 0
		$AnimatedSprite2D.play("Forward")
		$AnimatedSprite2D.set_frame_and_progress(current_frame, current_progress)
		

	if (Input.is_action_pressed("buster") && Input.is_action_pressed("move_left")):
		sprite.scale.x = -1
		
	if (Input.is_action_pressed("buster") && Input.is_action_pressed("move_right")):
		sprite.scale.x = 1
		


	if buster_timer > 10:
		$Buster.play()
		projectile = preload("res://scenes/objects/players/weapons/bass/track_2_buster.tscn").instantiate()
		get_parent().add_child(projectile)
		
		projectile.position.x = position.x
		projectile.position.y = position.y
		
		match aim:
			-1:
				projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
				projectile.velocity.y = (buster_speed * 0.5)
				projectile.position.x = position.x + sprite.scale.x * 14
				projectile.position.y = position.y + 10
			0:
				projectile.velocity.x = sign(sprite.scale.x) * buster_speed
				projectile.position.x = position.x + sprite.scale.x * 17
				projectile.position.y = position.y + 2
			1:
				projectile.velocity.x = sign(sprite.scale.x) * (buster_speed * 0.5)
				projectile.velocity.y = -(buster_speed * 0.5)
				projectile.position.x = position.x + sprite.scale.x * 14
				projectile.position.y = position.y + -6
			2:
				projectile.velocity.y = -buster_speed
				projectile.position.x = position.x + sprite.scale.x * 2
				projectile.position.y = position.y - 17
		
		buster_timer = 0
