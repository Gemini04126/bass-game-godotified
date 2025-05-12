extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CB_GUERILLA

var checker: String 
var explosion = preload("res://scenes/objects/explosion_1.tscn")
var fx

func _ready():
	fx = explosion.instantiate()
	add_sibling(fx)
	fx.position = position
	fx.muted = true
	fx.position.x += randfn(0,18)
	fx.position.y += randfn(0,8)
	
	fx = explosion.instantiate()
	add_sibling(fx)
	fx.position = position
	fx.muted = true
	fx.position.x += randfn(0,8)
	fx.position.y += randfn(0,18)
	
func destroy():
	pass

func kill():
	pass
	
func reflect():
	pass

func _physics_process(_delta):
	queue_free()
