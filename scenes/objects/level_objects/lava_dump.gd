extends CharacterBody2D

func _physics_process(delta):
	if !GameState.freezeframe:
		position.y += 4
	
func _on_hurt_body_entered(body):
	body.DmgQueue = 50
