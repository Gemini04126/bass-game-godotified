extends Node2D
var timer : int = 0
func _ready() -> void:
	await Fade.fade_in().finished
	$ForteEngine.play()
	
func _physics_process(delta):
	timer += 1
	if timer == 245:
		Fade.fade_out()
	if timer > 400:
		Fade.fade_in()
		get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
			
