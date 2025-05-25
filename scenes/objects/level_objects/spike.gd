extends StaticBody2D

class_name Spike
@export var damage : int

func _on_hurt_body_entered(body):
	if damage == 0:
		if GameState.upgrades_enabled[8] == true:
			body.DmgQueue = 14
		else:
			body.DmgQueue = 150
	else:
		if GameState.upgrades_enabled[8] == true:
			body.DmgQueue = damage / 2
		else:
			body.DmgQueue = damage
