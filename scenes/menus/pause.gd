class_name Pause_Screen extends CanvasLayer
var pause : bool = false

func _ready() -> void:
	if GameState.character_selected != 1:
		$BassWeps.queue_free()
	if GameState.character_selected != 2 and GameState.character_selected != 0:
		$CopyWeps.queue_free()

func _process(_delta):
	if $TransTimer.is_stopped() and pause != true:
		get_tree().paused = true
		pause = true
		
	if Input.is_action_just_pressed("start") and $TransTimer.is_stopped():
		$FadeBG.play("fadeout")
		get_tree().paused = false
		await $FadeBG.animation_finished
		queue_free()
		
	
	

func _on_item_list_item_selected(index):
	GameState.character_selected = index


func _on_item_list_2_item_selected(index):
	GameState.difficulty = index
