class_name BossDoor
extends StaticBody2D

static var static_audio_player : AudioStreamPlayer2D

@export var state : int

@export var scrollX1 : int ##Left bounds of the current room
@export var scrollX2 : int ##Right bounds of the current room
@export var scrollY1 : int ##Top bounds of the current room
@export var scrollY2 : int ##Bottom bounds of the current room

var closing 
var oldX1
var oldX2
var oldY1
var oldY2

var oldposx
var oldposy

var oldscalex
var oldscaley

@export var direction : int ##right = 1 down = 2 left = 3 up = 4

@export var screenmode : int

@export var ladderonly : bool

func _physics_process(delta):
	if GameState.screentransiton > 0 and GameState.screentransiton < 40 :
		if $Top.position.y >= -48:
			$Top.position.y -= 2
			$Bottom.position.y += 2
	
	if GameState.transdir == 0:
		if $Top.position.y < -16:
			$Top.position.y += 2
			$Bottom.position.y -= 2

func _on_open_trigger_body_entered(body):
	GameState.bossdoor = true
	print("yo")
	if body.is_in_group("player") && GameState.transdir == 0:
		if ladderonly == false or GameState.playerstate == 7:
			if scrollX1 != GameState.scrollX1 or scrollX2 != GameState.scrollX2 or scrollY1 != GameState.scrollY1 or scrollY2 != GameState.scrollY2:
				
				#old screen bounds
				GameState.scrollX3 = GameState.scrollX1
				GameState.scrollX4 = GameState.scrollY2
				GameState.scrollY3 = GameState.scrollX1
				GameState.scrollY4 = GameState.scrollY2
				
				#new screen bounds
				GameState.scrollX1 = scrollX1
				GameState.scrollX2 = scrollX2
				GameState.scrollY1 = scrollY1
				GameState.scrollY2 = scrollY2
		
				GameState.screentransiton = 50
				GameState.transdir = direction
					



func _on_close_trigger_body_entered(body):
	closing = true
