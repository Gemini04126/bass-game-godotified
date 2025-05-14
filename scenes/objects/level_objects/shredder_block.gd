@tool
class_name ShredderBlock
extends StaticBody2D

const styles = [
	"Test",
	"Blaze",
	"Video",
	"Smog",
	"Shark",
	"Origami",
	"Gale",
	"Guerrilla",
	"Reaper"
]

var gravity = 1400

var _style : int = 0
## Yoku Block sprite set to display
@export var style : int :
	get:
		return _style
	set(value):
		if Engine.is_editor_hint():
			if (value < styles.size()) && (value >= 0):
				_style = value;
				$AnimatedSprite2D.play(styles[style])

func _ready():
	$AnimatedSprite2D.play(styles[style])

func _on_hitable_body_entered(weapon):
	if weapon.W_Type == GameState.DMGTYPE.CR_SHARK1 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK2 or weapon.W_Type == GameState.DMGTYPE.BS_SHARK:
		$Collision.queue_free()
		$hitable.queue_free()
		$AnimatedSprite2D.play("Explode")
		await $AnimatedSprite2D.animation_finished
		queue_free()
	else:
		weapon.reflect()
	
