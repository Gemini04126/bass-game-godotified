extends Node2D

func _physics_process(delta: float) -> void:
	if GameState.scrollX1 > 1 and GameState.scrollY1 > 3 and GameState.scrollY2 < 5 and GameState.camposy > 800:
		$CityBG2.visible = true
		$CityBG.visible = false
	else:
		$CityBG2.visible = false
		$CityBG.visible = true
