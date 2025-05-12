extends AnimatableBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Move down by 2 pixels at nearly the same velocity as the constant linear one.
	$Graphics/Top.frame = 1
	pass # Replace with function body.

func _on_area_2d_body_exited(body: Node2D) -> void:
	$Graphics/Top.frame = 0

func _physics_process(delta: float) -> void:
	move_and_collide(Vector2.UP * (delta * 15), false, 0.08, true)
	if GameState.player != null:
		$Graphics/Top.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
		$Graphics/Bottom.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))

#	if GameState.current_weapon != 11: # Would use the enum, but... you get the idea by now
#		destroy()

func destroy() -> void:
	GameState.onscreen_sp_bullets -= 1
	var splod = preload("res://scenes/objects/explosion_1.tscn").instantiate()
	add_sibling(splod)
	splod.position = position
	queue_free()

func _on_timer_timeout() -> void:
	destroy()
