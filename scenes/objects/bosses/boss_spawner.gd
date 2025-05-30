@tool

extends Node2D

class_name boss_spawner
var oldposx
var oldposy
var oldtype : int
var olddirection: int
var readied : bool

@export_enum ("Test Boss", "Shark Man") var type : int ##The type of enemy.
@export_enum ("Mute", "Stage", "Boss", "FortBoss", "Wily") var music : int ##Music to play
@export var dontchangemusic : bool ##Check this if you don't want the music to change!

@export var slot : int
@onready var baby
var enemytype = [
	preload("res://scenes/objects/bosses/testboss.tscn"),
	preload("res://scenes/objects/bosses/shark_man.tscn")
]

func _on_visible_on_screen_notifier_2d_screen_entered():
	if not Engine.is_editor_hint():
		readied = true

func _process(_delta):
	if not Engine.is_editor_hint():
		if GameState.transdir == 0 && readied == true:
			GameState.bossfightstatus = 1
			baby = enemytype[type].instantiate()
			add_sibling(baby)
			baby.position = position
			GameState.bosses.append(baby)
			print(GameState.bosses)
			if dontchangemusic == false:
				GameState.musicplaying = music
			queue_free()
	if Engine.is_editor_hint():
		if baby == null:
			baby = enemytype[type].instantiate()
			add_sibling(baby)
			baby.position = position
			
		if baby != null:
			if oldposx != position.x:
				baby.queue_free()
			if oldposy != position.y:
				baby.queue_free()
			if oldtype != type:
				baby.queue_free()
		
		oldposx = position.x
		oldposy = position.y
		oldtype = type
	else:
		pass
		
