class_name Lava_Dump extends AnimatedSprite2D
@export var interval = 5
var wait = 0
@onready var projectile

func _physics_process(_delta):
	if !GameState.freezeframe:
		if $Timer.paused:
			$Timer.paused = false
			play()
		if $Timer.is_stopped() && wait < interval:
			$Timer.start(1)
			wait += 1
			if wait == interval-1:
				play("warning")
			if wait == 0:
				play("idle")
			
		if $Timer.is_stopped() && wait >= interval:
			projectile = preload("res://scenes/objects/level_objects/lava_dump.tscn").instantiate()
			get_parent().add_child(projectile)
			projectile.position.x = position.x
			projectile.position.y = position.y
			projectile.velocity.y = 40
			wait = -3
			play("dump")
			$Timer.start(0)
	else:
		$Timer.paused = true
		pause()
