extends CharacterBody2D

const W_Type = GameState.DMGTYPE.CR_BUSTER_1
var freezeframed

func _ready() -> void:
	if GameState.upgrades_enabled[15] == true:
		$AnimatedSprite2D.play("fast")

func _physics_process(_delta):
	move_and_slide()
	if GameState.freezeframe == true:
		freezeframed = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	GameState.onscreen_bullets -= 1
	queue_free()

func destroy():
	$CollisionShape2D.set_deferred("disabled", true)
	$HitSound.play()
	velocity.x = 0
	velocity.y = 0
	if GameState.upgrades_enabled[15] == true:
		$AnimatedSprite2D.play("hit2")
	else:
		$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	GameState.onscreen_bullets -= 1
	queue_free()

func kill():
	destroy()

func reflect():
	$ReflectSound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	velocity.x = -velocity.x
	velocity.y = -180
