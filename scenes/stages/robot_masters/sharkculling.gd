extends Node2D

var cull : int = 0

func _ready() -> void:
	$Foreground.queue_free()
	
func _physics_process(delta):
	if GameState.player != null:
		if GameState.player.position.y > 300 and $AboveWater.enabled == true :
			$AboveWater.enabled = false
			print("Above0")
			
			
		if GameState.player.position.x > 1200 and $UnderWater1.enabled == true:
			$UnderWater1.enabled = false
			print("Under1")
			
		if GameState.player.position.y > 900 and $UnderWater2.enabled == true:
			$UnderWater2.enabled = false
			print("Under2")
			
		if GameState.player.position.x > 6250 and $Cave.enabled == true:
			$Cave.enabled = false
			print("Cave")
