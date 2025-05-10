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

var oldX1
var oldX2
var oldY1
var oldY2

enum STATES {
	NONE, 
	TELEPORT, ##Teleporting down in a beam of energy
	TELEPORT_LANDING,
	IDLE,
	STEP,
	WALK,
	SLIDE,
	JUMP,
	FALL_START,
	FALL,
	FALL_SHOOT,
	LADDER,
	HURT,
	IDLE_SHOOT,
	WALKING_SHOOT,
	LADDER_SHOOT,
	JUMP_SHOOT,
	IDLE_THROW,
	JUMP_THROW,
	FALL_THROW,
	IDLE_SHIELD,
	JUMP_SHIELD,
	FALL_SHIELD,
	DEAD,
	DASH,
	IDLE_AIM,
	IDLE_AIM_DOWN,
	IDLE_AIM_DIAG,
	IDLE_AIM_UP,
	JUMP_AIM,
	JUMP_AIM_DOWN,
	JUMP_AIM_DIAG,
	JUMP_AIM_UP,
	FALL_AIM,
	FALL_AIM_DOWN,
	FALL_AIM_DIAG,
	FALL_AIM_UP,
	AIR_DASH,
	PAPER_CUT,
	IDLE_FIN_SHREDDER,
	IDLE_DOUBLE_FIN_SHREDDER,
	JUMP_FIN_SHREDDER,
	JUMP_DOUBLE_FIN_SHREDDER,
	FALL_FIN_SHREDDER,
	WARPING, #Using a teleporter
	WARP2 #Leaving a teleporter
}

var icon
var oldposx
var oldposy

var oldscalex
var oldscaley

@export var direction : int ##right = 1 down = 2 left = 3 up = 4

@export var screenmode : int

@export var ladderonly : bool
@export var onetimeuse : bool = true
@export var smooth : bool = false

func _on_body_entered(body):
	print("yo")
	if body.is_in_group("player") && GameState.transdir == 0:
		if ladderonly == false or GameState.player.currentState == STATES.LADDER:
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
				
				if onetimeuse == true:
					queue_free()
