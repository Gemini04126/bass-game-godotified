@tool
extends Node2D
class_name YokuBlockHandler

var num
@export var intervals : int = 1

@export var interval1 : float = 1
@export var interval2 : float = 1
@export var interval3 : float = 1
@export var interval4 : float = 1
@export var interval5 : float = 1
@export var interval6 : float = 1
@export var interval7 : float = 1
@export var interval8 : float = 1
@export var interval9 : float = 1
@export var interval10 : float = 1

var interval = 0

func _physics_process(delta: float):
	if $Timer.is_stopped():
		interval += 1
		print("bwoop")
		if interval == intervals + 1:
			interval = 1
			
		if interval == 1:
			$Timer.start(interval1)
			#$Int1.get_child(0).activated = true
			
		if interval == 2:
			$Timer.start(interval2)
			#$Int2.get_child(0).activated = true
			
		if interval == 3:
			$Timer.start(interval3)
			#$Int3.get_child(0).activated = true
		
		if interval == 4:
			$Timer.start(interval4)
			#$Int4.get_child(0).activated = true
		
		if interval == 5:
			$Timer.start(interval5)
			#$Int5.get_child(0).activated = true
		
		if interval == 6:
			$Timer.start(interval6)
			#$Int6.get_child(0).activated = true
		
		if interval == 7:
			$Timer.start(interval7)
			#$Int7.get_child(0).activated = true
		
		if interval == 8:
			$Timer.start(interval8)
			#$Int8.get_child(0).activated = true
		
		if interval == 9:
			$Timer.start(interval9)
			#$Int9.get_child(0).activated = true
		
		if interval == 10:
			$Timer.start(interval10)
			#$Int10.get_child(0).activated = true
