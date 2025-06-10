extends CharacterBody2D
@onready var parent = get_parent().get_parent()

var baseposx : float
var baseposy : float

var theta : float # changed from int to float

var radius : int
var dist : float
var rotatedir : int

var durability : int = 6
var invul : int
var DmgQueue : int # make the game not crash when you touch an enemy
var speed : int

var freezeframed : bool = false #prevents crashing lol

var wet : bool
var fired : bool
var left : bool

func _ready() -> void:
	radius = 256

func _physics_process(_delta):
	if radius < 2:
		queue_free()
	
	baseposx = GameState.player.position.x
	baseposy = GameState.player.position.y

	theta += speed
	radius -= 4
	
	position.x = baseposx + cos(theta)*radius
	position.y = baseposy + sin(theta)*radius
