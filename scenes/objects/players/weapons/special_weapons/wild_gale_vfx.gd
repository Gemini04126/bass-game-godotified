extends AnimatedSprite2D

var animation_played = false

func _process(_delta):
	if GameState.player != null:
		$".".material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))

	if not animation_played:
		if GameState.character_selected == 2:
			play("Copy")
		else:
			play("Bass")
		animation_played = true
