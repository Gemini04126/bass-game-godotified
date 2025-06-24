class_name StageSelect extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.music.stop()
	var player := %Player as StageSelectPanel
	player.portrait.atlas = load(GameState.stageSelectPlayerPortraits[GameState.character_selected])
	# break and blank out completed and beaten bosses respectively
	if GameState.PROGRESSDICT.get("BlazeDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man".beaten = true
	if GameState.PROGRESSDICT.get("VideoDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Video Man".beaten = true
	if GameState.PROGRESSDICT.get("OrigamiDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Origami Man".beaten = true
	if GameState.PROGRESSDICT.get("GaleDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Gale Woman".beaten = true
	if GameState.PROGRESSDICT.get("GuerrillaDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Guerrilla Man".beaten = true
	if GameState.PROGRESSDICT.get("ReaperDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Reaper Man".beaten = true
	if GameState.PROGRESSDICT.get("SharkDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Shark Man".beaten = true
	if GameState.PROGRESSDICT.get("SmogDead") == true: $"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Smog Man".beaten = true
	
	await Fade.fade_in().finished
	%Player.grab_focus()

func _physics_process(_delta):
	await $Timer.timeout # G: turned timer int into a real timer using a node that was already here but unused
	$Darkness.hide()
	%Player.grab_focus()
	GameState.change_music(load("res://audio/music/Stage Select.ogg")) # Not at the very start of the scene; we have to wait for the fade-in
	$Rows/RowBright.play()
	
	$Background.material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$Rows.material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
		
	$"Rows/Row 2/RowPt1".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$"Rows/Row 2/RowPt2".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	$"Rows/Row 2/RowPt3".material.set_shader_parameter("palette", load(GameState.stageSelectColorTranslations[GameState.character_selected]))
	
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Blaze Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Video Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Smog Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Shark Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Player/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Origami Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Gale Woman/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Guerrilla Man/VBoxContainer/Portrait/PortraitFlash".play()
	$"MarginContainer/CenterContainer/VBoxContainer/GridContainer/Reaper Man/VBoxContainer/Portrait/PortraitFlash".play()
	
func panel_focused(index: int):
	var player := %Player as StageSelectPanel
	if not player: return
	var portrait := player.portrait as AtlasTexture
	if not portrait: return
	portrait.region.position.x = (floor(portrait.atlas.get_width()) / 9) * index
