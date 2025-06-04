extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CR_SHARK2
var dying : bool = false
var spins : int
var detectpos
var going : bool = false

func _ready():
	$SpawnSound.play()
	velocity.y = 0
	detectpos = GameState.player.position.y
		
		
func _physics_process(_delta):
	move_and_slide()
	
	if !is_on_floor() and $Projectile.visible == true:
		$Projectile2.visible = true
	else:
		$Projectile2.visible = false
		
				
	
	if GameState.player != null:
		$Projectile.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
		$Spinner.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
	if GameState.current_weapon != GameState.WEAPONS.SHARK:
		queue_free()
		
	if $Projectile.animation == "Copy" and $Projectile.frame == 4:
		$Projectile.play("Copy-loop")
		$Projectile2.play("Copy-loop")
	
	if dying == true:
		if ($Projectile.get_frame() == 0):
			velocity.x = velocity.x * 0.7
		velocity.x = velocity.x * 0.8
		if ($Projectile.get_frame() == 1):
			GameState.onscreen_sp_bullets = 0
			queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_sp_bullets = 0
	queue_free()

func destroy():
	$HitSound.play()
	velocity.y = 0
	$Projectile.play("Copy-hit")
	$Projectile2.play("Copy-hit")
	dying = true
	
	

func kill():
	pass

func reflect():
	pass

func _on_spinner_animation_looped() -> void:
	if going == false:
		spins += 1
		velocity.x *= 1.9
		if spins > 2:
			if detectpos == GameState.player.position.y:
				velocity.x = velocity.x * 344
				$SpawnSound.play()
				$Spinner.visible = false
				$Projectile.visible = true
				$Projectile.play("Copy")
				$Projectile2.play("Copy")
				going = true
				GameState.weapon_energy[GameState.WEAPONS.SHARK] -= 2
		if spins == 10 and going == false:
			queue_free()

func _on_projectile_animation_finished() -> void:
	pass
