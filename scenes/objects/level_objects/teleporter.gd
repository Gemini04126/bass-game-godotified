extends Node2D

class_name teleporter

static var static_audio_player : AudioStreamPlayer2D


## Left bounds of the next room
@export var scrollX1 : int 
## Right bounds of the next room
@export var scrollX2 : int 
## Top bounds of the next room
@export var scrollY1 : int 
## Bottom bounds of the next room
@export var scrollY2 : int 

## Teleport destination x
@export var destinationx : int 
## Teleport destination y
@export var destinationy : int 

@export var disabled : bool 

var teleporting : bool

var oldposx
var oldposy

var oldscalex
var oldscaley

func _physics_process(_delta):
	$Trigger/Trigger.disabled = disabled
	
	if teleporting == true and $Timer.is_stopped():
		
		GameState.scrollX1 = scrollX1
		GameState.scrollX2 = scrollX2
		GameState.scrollY1 = scrollY1
		GameState.scrollY2 = scrollY2
		GameState.player.position.x = (destinationx * 16) + (GameState.scrollX1 * 384)
		GameState.player.position.y = (destinationy * 16) + (GameState.scrollY1 * 216)
		
		teleporting = false
		GameState.player.warping = 2 

func _on_trigger_body_entered(body):
	if body.is_in_group("player"):
		disabled = true
		teleporting = true
		GameState.player.warping = 1 
		$Timer.start(0.35)
	
