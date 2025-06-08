@tool

extends Node2D

class_name boss_spawner
var oldposx
var oldposy
var oldtype : int
var olddirection: int
var readied : bool

@export_enum ("Test Boss", "Shark Man", "Blaze Man") var type : int ##The type of enemy.
@export_enum ("Mute", "Stage", "Boss", "FortBoss", "Wily") var music : int ##Music to play
@export var dontchangemusic : bool ##Check this if you don't want the music to change!
@export var fullintro : bool ##Check this if you don't want the music to change!

@export var slot : int
@onready var baby
var enemytype = [
	preload("res://scenes/objects/bosses/testboss.tscn"),
	preload("res://scenes/objects/bosses/shark_man.tscn"),
	preload("res://scenes/objects/bosses/blaze_man.tscn")
]

func _on_visible_on_screen_notifier_2d_screen_entered():
	if not Engine.is_editor_hint():
		readied = true

func _process(_delta):
	if not Engine.is_editor_hint():
		$Icon.visible = false
		$Music.visible = false
		$Intro.visible = false
		if GameState.player != null:
			if GameState.transdir == 0 && readied == true && GameState.player.is_on_floor():
				GameState.bossfightstatus = 1
				baby = enemytype[type].instantiate()
				add_sibling(baby)
				baby.position = position
				GameState.bosses.append(baby)
				print(GameState.bosses)
				baby.fullintro = fullintro
				if dontchangemusic == false:
					GameState.musicplaying = music
				queue_free()
	if Engine.is_editor_hint():
		$Icon.frame = type
		if dontchangemusic == false:
			$Music.text = "%s" % music
		else:
			$Music.text = "X"
		if fullintro == true:
			$Intro.text = "Y"
		else:
			$Intro.text = "N"
	else:
		pass
		
