extends Node2D

class_name secretteleporter

static var static_audio_player : AudioStreamPlayer2D


## Left bounds of the next room
@export var scrollX1 : int 
## Right bounds of the next room
@export var scrollX2 : int 
## Top bounds of the next room
@export var scrollY1 : int 
## Bottom bounds of the next room
@export var scrollY2 : int 

## Blocks from X1's left edge to teleport to
@export var destinationX : int 
## Blocks from Y1's top edge to teleport to
@export var destinationY : int 

@export var disabled : bool 

var teleporting : bool

var oldposx
var oldposy

var oldscalex
var oldscaley

func _physics_process(_delta):
	$Trigger/Trigger.disabled = disabled
	
	if GameState.player != null:
		if GameState.player.position.x > position.x:
			scale.x = -1
		if GameState.player.position.x < position.x:
			scale.x = 1
	
	if teleporting == true and $Timer.is_stopped():
		
		GameState.scrollX1 = scrollX1
		GameState.scrollX2 = scrollX2
		GameState.scrollY1 = scrollY1
		GameState.scrollY2 = scrollY2
		GameState.player.position.x = (destinationX * 16) + (GameState.scrollX1 * 384)
		GameState.player.position.y = (destinationY * 16) + (GameState.scrollY1 * 216)
		
		teleporting = false
		GameState.player.warping = 2

func _on_trigger_body_entered(body):
	if body.is_in_group("player"):
		
		GameState.player.position.x = position.x
		disabled = true
		teleporting = true
		GameState.player.warping = 1 
		$Timer.start(0.35)
	
