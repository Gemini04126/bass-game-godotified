extends AnimatedSprite2D

var animation_played = false

func _process(_delta):
	if GameState.player != null:
		$".".material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	await animation_finished
	queue_free()
