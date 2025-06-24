class_name TitleScreen extends CanvasLayer

func _ready() -> void:
	$CenterContainer/HBoxContainer/VBoxContainer/ItemList.select(GameState.character_selected, true)
	GameState.change_music(load("res://audio/music/Title Screen.mp3"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("start"):
		_on_startbutton_pressed()

func _on_startbutton_pressed():
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/menus/stage_select.tscn")

func _on_item_list_item_selected(index):
	GameState.character_selected = index


func _on_item_list_2_item_selected(index):
	GameState.difficulty = index
