extends CharacterBody2D

var W_Type = GameState.DMGTYPE.MD_ORIGAMI
var timer : int = 0

func _ready():
	pass

func _physics_process(_delta):
	move_and_slide()
	timer += 1
	if timer > 10:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy():
	pass

func reflect():
	$ReflectSound.play()

func kill():
	pass
