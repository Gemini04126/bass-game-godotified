@tool
class_name WeaponSelector extends CenterContainer

@export var item : int
var firsttick : bool = true

var selected: bool
var hovered: bool

var BWEAPONS = [
	"B.BUSTER",
	"SCORCH B.",
	"FREEZE F.",
	"POISON C.",
	"F.SHREDDER",
	"ORIGAMI S.",
	"WILD GALE",
	"ROLLING B.",
	"B.SCYTHE",
	"P.STRIKE",
	"T.ASSIST"
]


var MODULES = [
	"B.BUSTER",
	"BLAST J.",
	"TRACK-2",
	"M.DASH",
	"S.SOUL",
	"PAPER C.",
	"A.GLIDER",
	"MACHINE B.",
	"DEAD DASH",
	"P.SHIELD",
	"",
	"",
	"",
	"",
	"",
	""
]

var CWEAPONS = [
	"C.BUSTER",
	"SCORCH B.",
	"FREEZE F.",
	"POISON C.",
	"F.SHREDDER",
	"ORIGAMI S.",
	"WILD GALE",
	"ROLLING B.",
	"B.SCYTHE",
	"10",
	"T.ASSIST",
	"F.CARRY",
	"S.ARROW",
	"MIRROR B.",
	"SCREW C.",
	"BALLADE C.",
	"SAKUGARNE"
	
]

var MWEAPONS = [
	"M.BUSTER",
	"SCORCH B.",
	"FREEZE F.",
	"POISON C.",
	"F.SHREDDER",
	"ORIGAMI S.",
	"WILD GALE",
	"ROLLING B.",
	"B.SCYTHE"
]

var PWEAPONS = [
	"P.BUSTER",
	"SCORCH B.",
	"FREEZE F.",
	"POISON C.",
	"F.SHREDDER",
	"ORIGAMI S.",
	"GALE FORCE",
	"ROLLING B.",
	"B.SCYTHE",
	"P.SHIELD",
	"TREBLE.A",
	"F.CARRY",
	"S.ARROW",
	"MIRROR B.",
	"SCREW C.",
	"BALLADE C.",
	"SAKUGARNE"
	
]


var MOD2 = [
	"",
	"^+JUMP (AIR)",
	"^+DASH",
	";+DASH",
	"JUMP (WATER)",
	"ATK+DASH",
	"JUMP (AIR)",
	"ATK/BSTR",
	"DASH (AIR)",
	"STAY STILL",
	"DOGGY!!! COOL!"
	
]

var CHAR = [
	"M.BUSTER",
	"B.BUSTER",
	"C.BUSTER",
	"M.BUSTER",
	"P.BUSTER"
]

var BASSCOL = [
	preload("res://sprites/hud/WepSel/buster.png"), #BUSTER
	preload("res://sprites/hud/WepSel/orange.png"), #BLAZE
	preload("res://sprites/hud/WepSel/green.png"), #VIDEO
	preload("res://sprites/hud/WepSel/purple.png"), #SMOG
	preload("res://sprites/hud/WepSel/shredbass.png"), #SHARK
	preload("res://sprites/hud/WepSel/buster.png"), #ORIGAMI
	preload("res://sprites/hud/WepSel/purple.png"), #GALE
	preload("res://sprites/hud/WepSel/green.png"), #GUERRILLA
	preload("res://sprites/hud/WepSel/red.png"), #REAPER
	preload("res://sprites/hud/WepSel/red.png"), #PROTO
	preload("res://sprites/hud/WepSel/purple.png") #Treble
	
]

var COPYCOL = [
	preload("res://sprites/hud/WepSel/buster.png"), #BUSTER
	preload("res://sprites/hud/WepSel/crpurple.png"), #BLAZE
	preload("res://sprites/hud/WepSel/green.png"), #VIDEO
	preload("res://sprites/hud/WepSel/crsmog.png"), #SMOG
	preload("res://sprites/hud/WepSel/crshred.png"), #SHARK
	preload("res://sprites/hud/WepSel/buster.png"), #ORIGAMI
	preload("res://sprites/hud/WepSel/green.png"), #GALE
	preload("res://sprites/hud/WepSel/green.png"), #GUERRILLA
	preload("res://sprites/hud/WepSel/crpurple.png"), #REAPER
	preload("res://sprites/hud/WepSel/crpurple.png"), #PROTO
	preload("res://sprites/hud/WepSel/purple.png"), #Treble
	preload("res://sprites/hud/WepSel/red.png"), #CARRY
	preload("res://sprites/hud/WepSel/darkblue.png"), #ARROW
	preload("res://sprites/hud/WepSel/darkblue.png"), #ENKER
	preload("res://sprites/hud/WepSel/red.png"), #PUNK
	preload("res://sprites/hud/WepSel/crpurple.png"), #BALLADE
	preload("res://sprites/hud/WepSel/red.png") #QUINT
	
]

var MEGACOL = [
	preload("res://sprites/hud/WepSel/buster.png"), #BUSTER
	preload("res://sprites/hud/WepSel/orange.png"), #BLAZE
	preload("res://sprites/hud/WepSel/green.png"), #VIDEO
	preload("res://sprites/hud/WepSel/purple.png"), #SMOG
	preload("res://sprites/hud/WepSel/shredbass.png"), #SHARK
	preload("res://sprites/hud/WepSel/buster.png"), #ORIGAMI
	preload("res://sprites/hud/WepSel/purple.png"), #GALE
	preload("res://sprites/hud/WepSel/green.png"), #GUERRILLA
	preload("res://sprites/hud/WepSel/orange.png") #REAPER
	
]

var PROTCOL = [
	preload("res://sprites/hud/WepSel/buster.png"), #BUSTER
	preload("res://sprites/hud/WepSel/orange.png"), #BLAZE
	preload("res://sprites/hud/WepSel/green.png"), #VIDEO
	preload("res://sprites/hud/WepSel/purple.png"), #SMOG
	preload("res://sprites/hud/WepSel/shredbass.png"), #SHARK
	preload("res://sprites/hud/WepSel/buster.png"), #ORIGAMI
	preload("res://sprites/hud/WepSel/purple.png"), #GALE
	preload("res://sprites/hud/WepSel/green.png"), #GUERRILLA
	preload("res://sprites/hud/WepSel/orange.png") #REAPER
	
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if firsttick == true and not Engine.is_editor_hint():
		if item == GameState.current_weapon or (item == 0 and GameState.current_weapon == GameState.WEAPONS.BUSTER):
			grab_focus()
			selected = true
			firsttick = false
		
	$IconM.region_rect = Rect2 ((item-1)*16 , 0, 16, 32)
	$IconW.region_rect = Rect2 (item*16 , 0, 16, 32)
	
	if not Engine.is_editor_hint():
		$IconW.region_rect = Rect2 (item*16 , GameState.character_selected*32 - 32, 16, 32)
		if selected or hovered:
			if GameState.weapons_unlocked[item] == true:
				GameState.current_weapon = item
			$IconW.frame = 0
			$IconM.frame = 0
			$Bar.region_rect = Rect2 (72 , 0, 72, 232)
			if GameState.character_selected == 1:
				$Bar.material.set_shader_parameter("palette", BASSCOL[item])
			if GameState.character_selected == 2 or GameState.character_selected == 0:
				$Bar.material.set_shader_parameter("palette", COPYCOL[item])
			if GameState.character_selected == 3:
				$Bar.material.set_shader_parameter("palette", MEGACOL[item])
			if GameState.character_selected == 4:
				$Bar.material.set_shader_parameter("palette", PROTCOL[item])
			
		else:
			$IconW.frame = 1
			$IconM.frame = 1
			$Bar.region_rect = Rect2 (0 , 0, 72, 232)
			
		if GameState.character_selected == 1:
			$Text/WepName.text = "%s" % BWEAPONS[item]
		if GameState.character_selected == 2 or GameState.character_selected == 0:
			$Text/WepName.text = "%s" % CWEAPONS[item]
		if GameState.character_selected == 3:
			$Text/WepName.text = "%s" % MWEAPONS[item]
		if GameState.character_selected == 4:
			$Text/WepName.text = "%s" % PWEAPONS[item]

		
		if item == 0:
			if GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true:
				$Text/WepName.text = "%s" % MODULES[GameState.WEAPONS.GUERRILLA]
				$IconM.region_rect = Rect2 (GameState.WEAPONS.GUERRILLA*16 - 16, 0, 16, 32)
				$IconM.visible = true
				$IconW.visible = false
			else:
				$IconW.region_rect = Rect2 (0 , GameState.character_selected*32 - 32, 16, 32)
				$IconW.visible = true
				$IconM.visible = false
			$Text/WepName.visible = true
			$Bar.frame = GameState.current_hp
			$Bar2.frame = GameState.current_hp
			if GameState.upgrades_enabled[1] == false:
				$Bar.visible = true
			else:
				$Bar2.visible = true
				
			
		else:
			if GameState.character_selected == 1:
				$Text/ModName.text = "%s" % MODULES[item]
				$Text/ModHelp.text = "%s" % MOD2[item]
			
				if GameState.modules_enabled[item] == true:
					$Text/ModName.visible = true
					$Text/ModHelp.visible = true
					$IconM.visible = true
					$IconW.visible = false
					$Bar.visible = false
		
			if GameState.weapons_unlocked[item] == true:
				$Text/WepName.visible = true
				$IconW.visible = true
				$Text/ModName.visible = false
				$Text/ModHelp.visible = false
				$Bar.frame = GameState.weapon_energy[item]
				$Bar2.frame = GameState.weapon_energy[item]
				if GameState.upgrades_enabled[2] == false:
					$Bar.visible = true
				else:
					$Bar2.visible = true
				
			
			else:
				$Bar.visible = false
				$IconW.visible = false
				
	if Engine.is_editor_hint():
		$IconW.frame = 0
		$IconW.visible = true
		$Bar2.visible = true
		
		
func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			hovered = true
			$SelectSound.play()
		NOTIFICATION_MOUSE_EXIT:
			hovered = false
		NOTIFICATION_FOCUS_ENTER:
			selected = true
			$SelectSound.play()
		NOTIFICATION_FOCUS_EXIT:
			selected = false


func _on_focus_entered():
	selected = true
	$SelectSound.play()


func _on_focus_exited():
	selected = false
