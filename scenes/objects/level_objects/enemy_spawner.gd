@tool

extends Node2D

class_name enemy_spawn
var oldposx
var oldposy
var oldtype : int
var oldsubtype : int
var olddirection: int
var readytospawn : bool = true
var onscreen : bool = false

@export_enum ("Sniper Joe", "Gabyoall", "Shotman", "Wanaan Kai", "Commando Joe", "Sutsi", "Tosser", "Jumbro") var type : int ##The type of enemy.
@export var direction : int
@export var subtype : int ##Variation on the enemy.
@onready var baby

@export var easy : bool = false
@export var normal : bool = false
@export var hard : bool = false
@export var vhard : bool = false

var enemytype = [
	preload("res://scenes/objects/enemies/sniper_joe.tscn"),
	preload("res://scenes/objects/enemies/gabyoall.tscn"),
	preload("res://scenes/objects/enemies/shotman.tscn"),
	preload("res://scenes/objects/enemies/wanaan_kai.tscn"),
	preload("res://scenes/objects/enemies/commando_joe.tscn"),
	preload("res://scenes/objects/enemies/sutsi.tscn"),
	preload("res://scenes/objects/enemies/tosser.tscn"),
	preload("res://scenes/objects/enemies/jumbro.tscn")
]
			
func _ready() -> void:
	if not Engine.is_editor_hint():
		$Info.queue_free()
		if (
			(GameState.difficulty == 0 and easy == false) or
			(GameState.difficulty == 1 and normal == false) or
			(GameState.difficulty == 2 and hard == false) or
			(GameState.difficulty == 3 and vhard == false)
		):
			queue_free()
	
func _process(_delta):
	if not Engine.is_editor_hint():
		
		if (position.x > GameState.camposx - 212 and position.x < GameState.camposx + 212) and (position.y > GameState.camposy - 252 and position.y < GameState.camposy + 252):
			onscreen = true
		else:
			onscreen = false
		
		if baby == null and GameState.transdir == 0 and readytospawn == true and onscreen == true:
			baby = enemytype[type].instantiate()
			add_sibling(baby)
			baby.subtype = subtype
			baby.position = position
			readytospawn = false
			if direction == 1: 
				baby.scale.x = -1
				
		if baby == null and onscreen == false:
			readytospawn = true
				
	if Engine.is_editor_hint():
		$Info/SubType.text = "%s" % subtype
		$Info/E.visible = easy
		$Info/N.visible = normal
		$Info/H.visible = hard
		$Info/V.visible = vhard
		
		
		if baby == null:
			baby = enemytype[type].instantiate()
			add_sibling(baby)
			baby.position = position
			if direction == 1: 
				baby.scale.x = -1
			
		if baby != null:
			if oldposx != position.x:
				baby.queue_free()
			if oldposy != position.y:
				baby.queue_free()
			if oldtype != type:
				baby.queue_free()
			if olddirection != direction:
				baby.queue_free()
		
		oldposx = position.x
		oldposy = position.y
		oldtype = type
		oldsubtype = subtype
		olddirection = direction
	else:
		pass
