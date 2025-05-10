extends AnimatedSprite2D

var muted = true
var animation_played = false

func _ready() -> void:
	if muted != true:
		$AudioStreamPlayer.play()

func _process(_delta):
	await animation_finished
	queue_free()
