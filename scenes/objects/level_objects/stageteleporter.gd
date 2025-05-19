extends Node2D

class_name teleporter

static var static_audio_player : AudioStreamPlayer2D

@export_enum ("Enker", "Ballade", "Punk", "Quint") var destination : int

var teleporting : bool

var oldposx
var oldposy

var oldscalex
var oldscaley

var timer : int = 0

func _physics_process(_delta):
	
	if teleporting == true and $Timer.is_stopped():
		timer += 1
		
		if timer == 10:
			GameState.player.queue_free()
		
		if timer == 15:
			$CanvasLayer/Fade.play("yeah")
		
		
		if timer == 60:
			match destination:
				0:
					get_tree().change_scene_to_file("res://scenes/stages/megaman_killers/enker.tscn")
				1:
					get_tree().change_scene_to_file("res://scenes/stages/megaman_killers/punk.tscn")
				2:
					get_tree().change_scene_to_file("res://scenes/stages/megaman_killers/ballade.tscn")
				3:
					get_tree().change_scene_to_file("res://scenes/stages/megaman_killers/quint.tscn")
			
func _on_trigger_body_entered(body):
	if body.is_in_group("player"):
		teleporting = true
		GameState.player.warping = 1 
		$Timer.start(0.35)
	
