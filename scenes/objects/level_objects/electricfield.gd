extends StaticBody2D

## how high doorprogress needs to be
@export var requirement : int

var deactivated : bool = false

func _physics_process(delta: float) -> void:
	$Top.frame = clamp(requirement - GameState.doorprogress, 0, 7)
	$Bottom.frame = clamp(requirement - GameState.doorprogress, 0, 7)
	
	if requirement == GameState.doorprogress and deactivated == false:
		deactivated = true
		$Electricity.queue_free()
		$ElectricWall.queue_free()
		$"Hurt/OUCH!".queue_free()


func _on_hurt_body_entered(body):
	body.DmgQueue = 2
