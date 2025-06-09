class_name BossDoor
extends StaticBody2D

static var static_audio_player : AudioStreamPlayer2D

@export var state : int

## Left bounds of the next room
@export var scrollX1 : int 
## Right bounds of the next room
@export var scrollX2 : int 
## Top bounds of the next room
@export var scrollY1 : int 
## Bottom bounds of the next room
@export var scrollY2 : int 

var closing 
var opening : bool
var oldX1
var oldX2
var oldY1
var oldY2

var oldposx
var oldposy

var oldscalex
var oldscaley

## right = 1 down = 2 left = 3 up = 4
@export var direction : int 

## 0: Right, 1: Left,
@export var way : int 

@export var screenmode : int
@export var checkpoint : int

@export var ladderonly : bool

func _ready():
	if way == 0:
		$OpenTrigger/OpenTriggerRight.queue_free()
	if way == 1:
		$OpenTrigger/OpenTriggerLeft.queue_free()

func _physics_process(_delta):
	if GameState.screentransiton > 0 and GameState.screentransiton < 40 and opening == true:
		if $Top.position.y >= -48:
			$Top.position.y -= 2
			$Bottom.position.y += 2
	
	if GameState.transdir == 0:
		opening = false
		if $Top.position.y < -16:
			$Top.position.y += 2
			$Bottom.position.y -= 2

func _on_open_trigger_body_entered(body):
	GameState.bossdoor = true
	opening = true
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
					
				if checkpoint != 0:
					GameState.checkpoint = checkpoint



func _on_close_trigger_body_entered(_body):
	closing = true
