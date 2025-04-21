@tool

extends Node2D

class_name boss_spawner
var oldposx
var oldposy
var oldtype : int
var olddirection: int
var readied : bool

@export var type : int ##The type of enemy.
@export var slot : int
@onready var baby
var enemytype = [
	preload("res://scenes/objects/bosses/testboss.tscn")
]

func _on_visible_on_screen_notifier_2d_screen_entered():
	if not Engine.is_editor_hint():
		readied = true

func _process(_delta):
	if not Engine.is_editor_hint():
		if GameState.transdir == 0 && readied == true:
			GameState.bossfightstatus = 1
			baby = enemytype[type].instantiate()
			get_parent().add_child(baby)
			baby.position = position
			
			if slot == 0:
				GameState.boss1 = baby
			if slot == 1:
				GameState.boss2 = baby
			if slot == 2:
				GameState.boss3 = baby
			if slot == 3:
				GameState.boss4 = baby
			if slot == 4:
				GameState.boss5 = baby
			if slot == 5:
				GameState.boss6 = baby
			if slot == 6:
				GameState.boss7 = baby
			if slot == 7:
				GameState.boss8 = baby
				
			queue_free()
	if Engine.is_editor_hint():
		if baby == null:
			baby = enemytype[type].instantiate()
			get_parent().add_child(baby)
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
		
