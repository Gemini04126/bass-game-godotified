extends Node2D

var fx
var count = 0

func _on_timer_timeout() -> void:
	fx = preload("res://scenes/objects/explosion_1.tscn").instantiate()
	add_sibling(fx)
	fx.position = position
	fx.position.x += randfn(0,16)
	fx.position.y += randfn(0,16)
	
	fx = preload("res://scenes/objects/explosion_1.tscn").instantiate()
	add_sibling(fx)
	fx.position = position
	fx.position.x += randfn(0,16)
	fx.position.y += randfn(0,16)
	
	count += 1
	if count > 4:
		queue_free()
	$Timer.start(0.05)
