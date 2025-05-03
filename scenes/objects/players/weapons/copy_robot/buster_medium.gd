extends CharacterBody2D

const W_Type = GameState.DMGTYPE.CR_BUSTER_2
var freezeframed

func _ready():
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	
func _physics_process(_delta):
	move_and_slide()
	if GameState.freezeframe == true:
		freezeframed = true
	if GameState.player != null:
		$AnimatedSprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_bullets -= 1
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	GameState.onscreen_bullets -= 1
	queue_free()

func reflect():
	$ReflectSound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("reflect")
	velocity.x = -velocity.x
	velocity.y = -180

func kill():
	pass
