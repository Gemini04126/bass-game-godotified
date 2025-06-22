@tool
class_name ShredderBlock
extends StaticBody2D

@export_enum ("Test", "Blaze", "Video", "Smog", "Shark", "Origami", "Gale", "Guerrilla", "Reaper") var style : int = 0

func _process(delta: float) -> void:
	$Sprite.frame = style

func _on_hitable_body_entered(weapon):
	if weapon.W_Type == GameState.DMGTYPE.CR_SHARK1 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK2 or weapon.W_Type == GameState.DMGTYPE.BS_SHARK:
		queue_free()
	else:
		weapon.reflect()
	
