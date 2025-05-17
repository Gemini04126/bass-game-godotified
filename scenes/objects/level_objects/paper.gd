extends StaticBody2D

class_name Paypur
var flame = preload("res://scenes/objects/level_objects/flame.tscn")
var chudson

var spawning

var gridx : int = 0
var gridy : int = 0

var time : int = 120
var burning : bool = false

var tick : bool = false

func _physics_process(_delta):
	if GameState.transdir != 0:
		queue_free()
		
	if time <= 0:
		queue_free()
		
	if burning and time > 0:
		time -= 1


			

func _on_burnable_body_entered(weapon):
	if weapon.is_in_group("scorch") and burning == false:
		burning = true
		spawning = true
		
		while spawning == true:
			if (gridx + 1) <= scale.x:
				chudson = flame.instantiate()
				add_sibling(chudson)
				chudson.position.x = position.x + (gridx * 16)
				chudson.position.y = position.y + (gridy * 16)
				gridx += 1
				
			else:
				if (gridy + 1) < scale.y:
					gridy += 1
					gridx = 0
				else:
					spawning = false
		
		$Paperwall.queue_free()
		$Backing.queue_free()
	else:
		pass
