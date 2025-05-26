extends Node2D

func _process(delta: float) -> void:
	if GameState.player != null:
		$Sprite.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
