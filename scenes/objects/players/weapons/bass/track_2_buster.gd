extends CharacterBody2D

var W_Type = GameState.DMGTYPE.BS_BUSTER
var dead : bool
var speeded : bool
var frames : int

var charged : bool

func _ready():
	if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true:
		$Machine.play()
		W_Type = GameState.DMGTYPE.MD_GUERILLA
	else:
		$SpawnSound.play()
	

func _physics_process(delta):
	
	if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true && !dead:
		if charged == true:
			if velocity.y > 0:
				$AnimatedSprite2D.play("charged_dow")
			if velocity.y < 0 && velocity.x == 0:
				$AnimatedSprite2D.play("charged_up")
			if velocity.y < 0 && velocity.x != 0:
				$AnimatedSprite2D.play("charged_upfor")
			if velocity.y == 0:
				$AnimatedSprite2D.play("charged_for")
		else:
			if velocity.y > 0:
				$AnimatedSprite2D.play("machine_dow")
			if velocity.y < 0 && velocity.x == 0:
				$AnimatedSprite2D.play("machine_up")
			if velocity.y < 0 && velocity.x != 0:
				$AnimatedSprite2D.play("machine_upfor")
			if velocity.y == 0:
				$AnimatedSprite2D.play("machine_for")
		if speeded != true:
			if charged == true:
				velocity.x *= 1.75
				velocity.y *= 1.75
			else:
				velocity.x *= 1.5
				velocity.y *= 1.5
			speeded = true
	if frames == 2:
		frames = 1
	else:
		frames += 1
	
	if move_and_slide() == true:
		dead = true
		destroy()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func kill():
	if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true:
		pass
	else:
		destroy()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	dead = true
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func reflect():
	$ReflectSound.play()
	if velocity.y == 0:
		velocity.x *= -0.5
		if frames == 1:
			velocity.y = -velocity.x
		if frames == 2:
			velocity.y = velocity.x
	
	if velocity.x == 0:
		velocity.y *= -0.5
		if frames == 1:
			velocity.x = -velocity.y
		if frames == 2:
			velocity.x = velocity.y
