@tool
extends Area2D
class_name ScreenChange
## Left boundary of the current room.
@export var scrollX1 : int
## Right boundary of the current room.
@export var scrollX2 : int
## Top boundary of the current room.
@export var scrollY1 : int
## Bottom boundary of the current room.
@export var scrollY2 : int
## Direction the transition goes in.
@export_enum ("None", "Right", "Down", "Left", "Up") var direction : int = 1

@export var screenmode : int

@export var ladder_only : bool
@export var one_time_use : bool = true
@export var smooth : bool = false


var oldX1
var oldX2
var oldY1
var oldY2

var icon
var oldposx
var oldposy

var oldscalex
var oldscaley

func _on_body_entered(body):
	print("yo")
	if body.is_in_group("player") && GameState.transdir == 0:
		if ladder_only == false or GameState.player.currentState == GameState.player.STATES.LADDER:
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
		
				GameState.screenmode = screenmode
				
				if smooth == false:
					GameState.transdir = direction
					GameState.screentransiton = 25
				
				if one_time_use == true:
					queue_free()
