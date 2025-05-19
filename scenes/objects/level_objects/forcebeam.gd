extends StaticBody2D

class_name ForceBeam
@export var delay : int
var readytofire : bool = false
@export var direction : int = 1
@export var speed : int = 1
var ticks

func _ready() -> void:
	scale.x = direction
	
func _physics_process(delta: float) -> void:
	if readytofire == true and GameState.transdir == 0 and GameState.freezeframe == false:
		if delay > 0:
			delay -= 1
		if delay == 0:
			$Sound.play()
			delay = -1
		if delay == -1 and !$RayCast2D.is_colliding():
			scale.x += direction * speed
		
			
			
func _on_hurt_body_entered(body):
	body.forcebeamed = true
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	readytofire = true

func _on_hurt_body_exited(body):
	body.forcebeamed = false
