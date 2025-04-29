extends CharacterBody2D

var W_Type = GameState.DMGTYPE.CB_GUERILLA

var checker: String 
var explosion = preload("res://scenes/objects/explosion_1.tscn")
var fx

func _ready():
	fx = explosion.instantiate()
	get_parent().add_child(fx)
	fx.position = position
	fx.position.x += randfn(0,12)
	fx.position.y += randfn(0,8)
	
	fx = explosion.instantiate()
	get_parent().add_child(fx)
	fx.position = position
	fx.position.x += randfn(0,8)
	fx.position.y += randfn(0,12)
	
func destroy():
	pass

func kill():
	pass
	
func reflect():
	pass

func _physics_process(_delta):
	queue_free()
