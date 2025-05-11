extends Node2D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_up"):
		$DPad/Up.visible = true
	else:
		$DPad/Up.visible = false
	if Input.is_action_pressed("move_down"):
		$DPad/Down.visible = true
	else:
		$DPad/Down.visible = false
	if Input.is_action_pressed("move_left"):
		$DPad/Left.visible = true
	else:
		$DPad/Left.visible = false
	if Input.is_action_pressed("move_right"):
		$DPad/Right.visible = true
	else:
		$DPad/Right.visible = false
	
	if Input.is_action_pressed("dash"):
		$ButtonA/Pressed.visible = true
	else:
		$ButtonA/Pressed.visible = false
		
	if Input.is_action_pressed("shoot"):
		$ButtonB/Pressed.visible = true
	else:
		$ButtonB/Pressed.visible = false
		
	if Input.is_action_pressed("jump"):
		$ButtonC/Pressed.visible = true
	else:
		$ButtonC/Pressed.visible = false
		
	if Input.is_action_pressed("switch_left"):
		$ButtonX/Pressed.visible = true
	else:
		$ButtonX/Pressed.visible = false
		
	if Input.is_action_pressed("switch_right"):
		$ButtonY/Pressed.visible = true
	else:
		$ButtonY/Pressed.visible = false
		
	if Input.is_action_pressed("buster"):
		$ButtonZ/Pressed.visible = true
	else:
		$ButtonZ/Pressed.visible = false
	
	if Input.is_action_pressed("start"):
		$Start/Pressed.visible = true
	else:
		$Start/Pressed.visible = false
