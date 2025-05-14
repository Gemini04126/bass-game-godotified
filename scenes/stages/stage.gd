class_name Stage
extends Node2D

@onready var player # kind of the same thing as GameState.player, but not really? This one's used to *instantiate* the player.
@onready var splash  

@export var C1screenmode : int
@export var C1scrollX1 : int
@export var C1scrollX2 : int
@export var C1scrollY1 : int
@export var C1scrollY2 : int

@export var C2screenmode : int
@export var C2scrollX1 : int
@export var C2scrollX2 : int
@export var C2scrollY1 : int
@export var C2scrollY2 : int

@export var C3screenmode : int
@export var C3scrollX1 : int
@export var C3scrollX2 : int
@export var C3scrollY1 : int
@export var C3scrollY2 : int

var refilltimer : int

var voffset : int = 8

func _ready():
	var hud = preload("res://scenes/hud.tscn").instantiate()
	add_child(hud)
	GameState.galeforce = 0
	GameState.transdir = 0
	GameState.player = null
	GameState.playerposx = 0
	GameState.playerposy = 0
	if GameState.upgrades_enabled[1] == true:
		GameState.max_HP = 36
	else:
		GameState.max_HP = 28
		
	if GameState.upgrades_enabled[2] == true:
		GameState.max_WE = 36
	else:
		GameState.max_WE = 28
	
	
	$StartPosition/Sprite2D.queue_free()	# just delete the sprite2d instead of making it invisible. why have it stick around?


	$Camera2D.position = $StartPosition.position
	GameState.scrollX1 = C1scrollX1
	GameState.scrollX2 = C1scrollX2
	GameState.scrollY1 = C1scrollY1
	GameState.scrollY2 = C1scrollY2
	GameState.screenmode = C1screenmode
		
	
		
	await Fade.fade_in().finished
	$Music.play()
	$HUD/READY._do_ready_thing()
	await $HUD/READY.animation_finished
	var player_scene : PackedScene = load(
		GameState.characters[
			GameState.character_selected
		]
	)
	player = player_scene.instantiate()
	add_child(player)
	player.position.y = GameState.camposy - 130
	player.position.x = $StartPosition.position.x
	player.targetpos = $StartPosition.position.y
		
	if player.has_method("play_start_sound"): # G: Finally, a foolproof method to do this...
		player.play_start_sound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if GameState.bossfightstatus == 0:
		if GameState.freezeframe == true:
			$Music.stream_paused = true
		else:
			if $Music.stream_paused == true:
				$Music.stream_paused = false
	
	if GameState.bossfightstatus == 1:
		$Music.stop()
		$BossMusic.play()
		GameState.bossfightstatus = 2
		GameState.inputdisabled = true
		
	if GameState.bossfightstatus == 2 && (GameState.bosses[0] == null or GameState.bosses[0].Cur_HP == GameState.bosses[0].Max_HP):
		GameState.bossfightstatus = 3
		GameState.inputdisabled = false
		
	if GameState.bossfightstatus == 3:
		if GameState.freezeframe == true:
			$BossMusic.stream_paused = true
		else:
			if $BossMusic.stream_paused == true:
				$BossMusic.stream_paused = false
	process_camera()

func _physics_process(_delta: float):
	if GameState.player != null and GameState.screentransiton == 0:
		if GameState.player.position.x < $Camera2D.position.x - 184:
			GameState.player.position.x = $Camera2D.position.x  - 184
		if GameState.player.position.x > $Camera2D.position.x + 184:
			GameState.player.position.x = $Camera2D.position.x  + 184
	process_refills()
	process_drops()
	if GameState.screentransiton > 0:
		GameState.screentransiton -= 1
	
func process_drops():
	GameState.droptimer += 1
	if GameState.droptimer > 8:
		GameState.droptimer = 0
		
	GameState.itemtimer -= 1
	if GameState.itemtimer <= 0:
		GameState.itemtimer = 15
	
func process_camera():
			
	if GameState.transdir == 1 && ($Camera2D.position.x < (384*GameState.scrollX1) + 192):
		if GameState.screentransiton == 0:
			$Camera2D.position.x += 8
		if player != null:
			if GameState.screentransiton == 0:
				if GameState.bossdoor == true:
					player.position.x += 0.75
				else:
					player.position.x += 0.5
			player.transing = true
		
	elif GameState.transdir == 2 && ($Camera2D.position.y < (224*GameState.scrollY1)+108 + 8):
		if GameState.screentransiton == 0:
			$Camera2D.position.y += 6
		if player != null:
			if GameState.screentransiton == 0:
				if GameState.bossdoor == true:
					player.position.y += 2
				else:
					player.position.y += 1
			player.transing = true
		
	elif GameState.transdir == 3 && ($Camera2D.position.x > (384*GameState.scrollX2) + 192):
		if GameState.screentransiton == 0:
			$Camera2D.position.x -= 8
		if player != null:
			if GameState.screentransiton == 0:
				if GameState.bossdoor == true:
					player.position.x -=1
				else:
					player.position.x -= 0.5
			player.transing = true
		
	elif GameState.transdir == 4 && ($Camera2D.position.y > (224*GameState.scrollY2)+108 + 8):
		if GameState.screentransiton == 0:
				$Camera2D.position.y -= 6
		if player != null:
			if GameState.screentransiton == 0:
				if GameState.bossdoor == true:
					player.position.y  -= 2
				else:	
					player.position.y -= 1
			player.transing = true
		
	else:
		GameState.transdir = 0
		if player != null:
			player.transing = false
		
	
	if (player != null): # Null check!
		if (GameState.current_hp > 0):
			if (player.currentState != player.STATES.TELEPORT):

				

				if GameState.transdir == 0:
					if player.position.x > (384*GameState.scrollX1) + 192 and player.position.x < (384*GameState.scrollX2) + 192 and player.warping == 0:
						if player.position.x > $Camera2D.position.x + 8:
							$Camera2D.position.x += 8
						elif player.position.x < $Camera2D.position.x - 8:
							$Camera2D.position.x -= 8
						else:
							$Camera2D.position.x = player.position.x
					
					
					if (player.position.y > (224*GameState.scrollY1) + 104 + 8) and player.warping == 0:
						if (player.position.y > $Camera2D.position.y) and player.standing == true:
							$Camera2D.position.y += 3

						if (player.position.y > $Camera2D.position.y + 25 ) and player.standing != true:
							$Camera2D.position.y = player.position.y - 25

					if (player.position.y < (224*GameState.scrollY2) + 104 + 8) and player.warping == 0:
						if (player.position.y < $Camera2D.position.y) and player.standing == true:
							$Camera2D.position.y -= 3
								
						if (player.position.y < $Camera2D.position.y - 25 ) and player.standing != true:
							$Camera2D.position.y = player.position.y + 25
							
					if (player.position.y > $Camera2D.position.y - 2) and (player.position.y < $Camera2D.position.y + 2) and player.standing == true and player.warping == 0:
						$Camera2D.position.y = player.position.y
						
					if player.warping > 0:
						$Camera2D.position = player.position
						
					if $Camera2D.position.y < (224*GameState.scrollY1) + 104  + 8:
						$Camera2D.position.y = (224*GameState.scrollY1) + 104  + 8
					if $Camera2D.position.y > (224*GameState.scrollY2) + 104  + 8:
						$Camera2D.position.y = (224*GameState.scrollY2) + 104  + 8
					if $Camera2D.position.x < (384*GameState.scrollX1) + 192:
						$Camera2D.position.x = (384*GameState.scrollX1) + 192
					if $Camera2D.position.x > (384*GameState.scrollX2) + 192:
						$Camera2D.position.x = (384*GameState.scrollX2) + 192
					
					
				
						
			if player.position.y > $Camera2D.position.y + 120	:
				GameState.current_hp = 0
					
					

	else:

		if $Camera2D.position.y < (224*GameState.scrollY1) + 104  + 8:
			$Camera2D.position.y = (224*GameState.scrollY1) + 104  + 8
		if $Camera2D.position.y > (224*GameState.scrollY2) + 104  + 8:
			$Camera2D.position.y = (224*GameState.scrollY2) + 104  + 8

		if $Camera2D.position.x < (384*GameState.scrollX1) + 192:
			$Camera2D.position.x = (384*GameState.scrollX1) + 192
		if $Camera2D.position.x > (384*GameState.scrollX2) + 192:
			$Camera2D.position.x = (384*GameState.scrollX2) + 192

	GameState.camposx = $Camera2D.position.x
	GameState.camposy = $Camera2D.position.y
	
	if GameState.screentransiton != 0:
		if GameState.transdir == 1 or GameState.transdir == 3:
			if $Camera2D.position.y < (224*GameState.scrollY1) + 104  + 8:
				$Camera2D.position.y += 8
			if $Camera2D.position.y > (224*GameState.scrollY2) + 104  + 8:
				$Camera2D.position.y -= 8
				
			#if $Camera2D.position.y < (224*GameState.scrollY3) + 104  + 8:
			#	$Camera2D.position.y = (224*GameState.scrollY3) + 104  + 8
			#if $Camera2D.position.y > (224*GameState.scrollY4) + 104  + 8:
			#	$Camera2D.position.y = (224*GameState.scrollY4) + 104  + 8
				
		if GameState.transdir == 2 or GameState.transdir == 4:
			if $Camera2D.position.x < (384*GameState.scrollX1) + 192:
				$Camera2D.position.x += 8
			if $Camera2D.position.x > (384*GameState.scrollX2) + 192:
				$Camera2D.position.x -= 8
				
			#if $Camera2D.position.x < (384*GameState.scrollX3) + 192:
			#	$Camera2D.position.x += 8
			#if $Camera2D.position.x > (384*GameState.scrollX4) + 192:
			#	$Camera2D.position.x -= 8
				
func process_refills():
	if (player != null): # Null check!
		if (GameState.ammoamt):
			if refilltimer == 0:
				if GameState.weapon_energy[GameState.current_weapon] < GameState.max_WE:
					refilltimer = 3
					GameState.weapon_energy[GameState.current_weapon] += 1
					GameState.ammoamt -= 1
				else:
					GameState.ammoamt = 0
			else:
				refilltimer -= 1
			
		if (GameState.healamt):
			if refilltimer == 0:
				if GameState.current_hp < GameState.max_HP:
					refilltimer = 3
					GameState.current_hp += 1
					GameState.healamt -= 1
				else:
					GameState.healamt = 0
			else:
				refilltimer -= 1
		
			
				


func _on_water_body_exited(dry):
	
	if dry.is_in_group("player"):
		dry.JUMP_VELOCITY = -225.0
		dry.PEAK_VELOCITY = -90.0	
		dry.STOP_VELOCITY = -80.0
		dry.JUMP_HEIGHT = 13
		dry.FAST_FALL = 400.0
		dry.in_water = false
		
	if dry.is_in_group("scorch"):
		dry.wet = false


func _on_water_body_entered(wet):
	if wet.is_in_group("player"):
		wet.JUMP_VELOCITY = -285.0
		wet.PEAK_VELOCITY = -110.0	
		wet.STOP_VELOCITY = -110.0
		wet.JUMP_HEIGHT = 23
		wet.FAST_FALL = 200.0
		wet.in_water = true
		
	if wet.is_in_group("scorch"):
		wet.wet = true
		

func _on_ice_body_entered(body):
	if body.is_in_group("player"):
		body.on_ice = true
		print("YeICE")


func _on_ice_body_exited(body):
	if body.is_in_group("player"):
		body.on_ice = false
		print("NoICE")


func _on_splash_zone_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.
