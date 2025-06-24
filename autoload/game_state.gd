extends CanvasLayer

@onready var projectile

#region Enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}
enum PALETTE {NONE, MD, NES, DOOM, LOSPEC2K, PICO8, GB, VB, C64, CGA, G4, G8, G16}
enum DMGTYPE
{
	#Shared DMG types between CR and Bass (CB)
	CB_SMOG,
	CB_REAPER_1,
	CB_REAPER_2,
	CB_ORIGAMI,
	CB_GALE,
	CB_GUERILLA,
	CB_PROTO_1,
	CB_PROTO_2,
	CB_PROTO_3,
	
	#Copy Robot Weapons (CR)
	CR_BUSTER_1,
	CR_BUSTER_2,
	CR_BUSTER_3,
	CR_BLAZE,
	CR_SHARK1,
	CR_SHARK2,
	CR_ARROW,
	CR_ENKER,
	CR_PUNK,
	CR_BALLADE,
	CR_QUINT1,
	CR_QUINT2,
	
	#Bass Weapons (BS)
	BS_BUSTER,
	BS_BLAZE,
	BS_SHARK,
	BS_TREBLE,
	
	#Bass Modules (MD)
	MD_BLAZE,
	MD_VIDEO,
	MD_ORIGAMI,
	MD_GUERILLA,
	MD_GUERILLA2,
	
	#MegaMan Weapons (MM)
	MM_VOLT,
	
	#Shared Proto/Rachel weps (PR)
	
	#ProtoMan Weapons (PM)
	
	#Rachel Weapons (RA)
	RA_BUSTER,
	RA_GALAXY,
	RA_TOP,
	RA_GEMINI,
	RA_GRENADE,
	RA_YAMATO,
	RA_MAGMA,
	RA_MAGMA2,
	RA_PHARAOH,
	RA_CHILL,
	RA_CHILL2,
	RA_WIRE,
	RA_TERRA,
	RA_MERCURY,
	RA_MARS,
	RA_PLUTO,
	RA_ROSE,
	
	#Instant Kill (KILL)
	KILL
}
#endregion
#region Constants
## Character names.
const char_names : Array[String] = [
	"Maestro",
	"Bass",
	"Copy Robot",
	"Mega Man",
	"Proto Man",
	"Rachel"
]
## Difficulty names.
const diff_names : Array[String] = [
	"Easy",
	"Normal",
	"Hard",
	"Very Hard"
]
const pal_names : Array[String] = [
	"None",
	"Mega Drive/Genesis",
	"NES",
	"Doom",
	"Lospec 2000",
	"Pico-8",
	"Game Boy (DMG)",
	"Virtual Boy",
	"Commodore 64",
	"CGA",
	"Grayscale (4)",
	"Grayscale (8)",
	"Grayscale (16)"
]
const palette_paths : Array[String] = [
	"", # None
	"res://shaders/palettes/megadrive.png", # Mega Drive/Genesis
	"res://shaders/palettes/nes.png", # NES
	"res://shaders/palettes/doom.png", # Doom
	"res://shaders/palettes/lospec-2000.png", # Lospec 2000
	"res://shaders/palettes/pico-8.png", # Pico-8
	"res://shaders/palettes/gameboy.png", # Game Boy (DMG)
	"res://shaders/palettes/virtualboy.png", # Virtual Boy
	"res://shaders/palettes/commodore64.png", # Commodore 64
	"res://shaders/palettes/cga.png", # CGA
	"res://shaders/palettes/grayscale4.png", # Grayscale (4)
	"res://shaders/palettes/grayscale8.png", # Grayscale (8)
	"res://shaders/palettes/grayscale16.png" # Grayscale (16)
]
#endregion
#region Variables
# G: hey, why don't we just change these to be enums at this point...?
## List of characters. Mods can add to this to add their own characters.
var characters : Array[String] = [
	"res://scenes/objects/players/maestro.tscn",
	"res://scenes/objects/players/bass.tscn",
	"res://scenes/objects/players/copy_robot.tscn",
	"res://scenes/objects/players/mega_man.tscn",
	"res://scenes/objects/players/maestro.tscn", # Protoman
	"res://scenes/objects/players/rachel/rachel.tscn" # Rachel gets her own folder because she has an ENTIRELY different weapon set
]
## List of life icon PNGs.
var lifeIcons : Array[String] = [
	"res://sprites/players/maestro/life.png",
	"res://sprites/players/bass/life.png",
	"res://sprites/players/copy_robot/life.png",
	"res://sprites/players/megaman/life.png",
	"res://sprites/players/protoman/life.png",
	"res://sprites/players/rachel/life.png"
]
## List of stage select portrait PNGs.
var stageSelectPlayerPortraits : Array[String] = [
	"res://sprites/players/maestro/stageselect.png",
	"res://sprites/players/bass/stageselect.png",
	"res://sprites/players/copy_robot/stageselect.png",
	"res://sprites/players/megaman/stageselect.png",
	"res://sprites/players/protoman/stageselect.png",
	"res://sprites/players/rachel/stageselect.png"
]
## List of stage select color translations. G: ...I couldn't make this pick Maestro's by default.
var stageSelectColorTranslations : Array[String] = [
	"res://sprites/players/maestro/stageseltrans.png",
	"res://sprites/players/bass/stageseltrans.png",
	"res://sprites/players/copy_robot/stageseltrans.png",
	"res://sprites/players/megaman/stageseltrans.png",
	"res://sprites/players/protoman/stageseltrans.png",
	"res://sprites/players/rachel/stageseltrans.png"
]

## Disables motion effects to prevent motion sickness.
var acessibility_motion : bool = false
## Disables flashing effects to prevent epilepsy.
var acessibility_flash : bool = false
## Currently selected palette.
var palette_selected : int = PALETTE.MD

## What the stage transition does -- going back to the stage select, weapon get screen, etc.
var stage_action : int
## What weapon the game gives the player upon beating the stage.
var stage_boss_weapon : int
## What part of the progress dict gets updated upon beating the stage.
var stage_progress_update : String = ""
## Whether or not a dialogue box is open.
var dialogue_open: bool = false

## Maximum valid character ID.
var maxCharacterID = characters.size() - 1 # Whyyyyy...?
## What character the player is playing as. Character is reloaded at scene load.
var character_selected : int
## How many lives the player has.
var player_lives : int = 3
## 0: No fight. 1: Boss intro. 2: Boss fight. 3: Player victory.
var bossfightstatus : int = 0
## How many bosses need to be killed to finish the stage.
var bossestokill : int = 0

## Whether music persists through deaths.
var continuous_music : bool = false

## Not sure what this does.
var pausescreen
## Amount of frames the game freezes when you die.
var hit_stop : int

## An array of boss nodes.
var bosses : Array[Node2D]

# TODO: Could be improved using object pooling
var onscreen_bullets : int
var onscreen_sp_bullets : int
var onscreen_track2s : int
var machinecharge : int = 0
var smogcharge : int = 0
var freezeframe : bool = false
var freezedelay : int = -5
var freezeticks : int = 0

var galeforce : float # converted from int to float

var playerstate
var middleroom : int

var inputdisabled : bool = false

#Camera Variables
var camposx
var camposy
var screenmode

#Current X and Y limits
var scrollX1 : int
var scrollX2 : int
var scrollY1 : int
var scrollY2 : int

#Old X and Y limits to respect the previous screen transition
var scrollX3 : int
var scrollX4 : int
var scrollY3 : int
var scrollY4 : int

#screen transition flags
var screentransiton : int
var bossdoor : bool
var transdir : int

var checkpoint : int
var doorprogress : int = 0

var paused_weapon : int

#player variables
var current_weapon : int
var old_weapon : int
var current_hp = 28
var bolts = 0
var ETanks = 0
var WTanks = 0
var STanks = 0
var max_HP = 28 # G: upgradeable # M: not upgradable anymore # G: yeah but mod characters :)) # M: what mod characters? # M: it's upgradeable again
var max_WE = 28 
var healamt = 0
var ammoamt = 0
var droptimer : int
var itemtimer : int

var damageticks : int

var PROGRESSDICT = {
	"BlazeDead": false,
	"VideoDead": false,
	"OrigamiDead": false,
	"GaleDead": false,
	"GuerrillaDead": false,
	"ReaperDead": false,
	"SharkDead": false,
	"SmogDead": false,
	"EnkerDead": false,
	"PunkDead": false,
	"BalladeDead": false,
	"QuintDead": false,
	"ProtoManDead": false,
	"Wily1Beaten": false,
	"Wily2Beaten": false,
	"Wily3Beaten": false,
	"Wily4Beaten": false,
	"Wily5Beaten": false,
	"Wily6Beaten": false,
	"TrebleRescued": false,
	"HaveProtoKey1": false,
	"HaveProtoKey2": false,
	"HaveProtoKey3": false,
	"HaveProtoKey4": false
}

var difficulty : int
var weapon_energy : Array = [
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]

var max_weapon_energy : Array = [
# G: Energy use is always 1, *no matter what*. Increase energy and max_energy values to have larger shot counts.
# M: what the hell are you talking about???
# G: i literally have no idea, i think i was trying to think of how we'd spend ammo in a more automatic way but like
# G: that's stupid
	0,	# Buster
	28,	# Scorch Barrier
	28,	# Freeze Frame
	28,	# Poison Cloud
	28,	# Fin Shredder
	28,	# Origami Star
	28,	# Wild Gale
	28,	# Rolling Bomb
	28,	# Boomerang Scythe
	28,	# Proto Buster
	28,	# Treble Boost
# CR-exclusive
	28,	# Carry
	28,	# Super Arrow
	28,	# Mirror Buster
	28,	# Screw Crusher
	28,	# Ballade Cracker
	28	# Sakugarne
]

var weapons_unlocked = [
	# Buster, under no circumstances should this be disabled
	true, # Buster
	# Special weapons shared between Bass and Copy Robot
	false, # Blaze
	false, # Video
	false, # Smog
	false, # Shark
	false, # Origami
	false, # Gale
	false, # Guerrilla
	false, # Reaper
	false, # Proto Buster
	#Bass Only
	false, # Treble Boost
	#Copy Robot Only
	false, # Carry
	false, # Super Arrow
	false, # Mirror Buster
	false, # Screw Crusher
	false, # Ballade Cracker
	false, # Sakugarne
]
var modules_unlocked = [
	true, # nothing lol
	false, # Blast Jump
	false, # Track 2
	false, # Mist Dash
	false, # Aqua Drive
	false, # Paper Cut
	false, # Aero Glide
	false, # Machine Buster
	false, # Spirit Dash
	false, # Proto Shield
	false, # CMON TREBLE!
]
var modules_enabled = [
	true, # nothing lol
	false, # Blast Jump
	false, # Track 2
	false, # Mist Dash
	false, # Aqua Drive
	false, # Paper Cut
	false, # Aero Glide
	false, # Machine Buster
	false, # Spirit Dash
	false, # Proto Shield
	false, # CMON TREBLE!
]
var modules_boosted = [
	true, # nothing lol
	false, # Blast Jump
	false, # Track 2
	false, # Mist Dash
	false, # Aqua Drive
	false, # Paper Cut
	false, # Aero Glide
	false, # Machine Buster
	false, # Spirit Dash
	false, # Proto Shield
	false, # CMON TREBLE!
]

var upgrades_enabled = [
	false, # HP up
	false, # WE up
	false, # Bullet up
	false, # Super Heal
	false, # Super Enrgy
	false, # Energy Balancer
	false, # Shock Absorber
	false, # Step Booster
	false, # Spike Protector
	false, # Tank Up
	false, # Chip Finder
	false, # Wall Pierce / Angle Buster
	false, # Rapid Buster / Speed Charge
	false, # Sprint Boost / Hyper Slide
	false, # Jump Boost
	false, # Mod1 / Speeding Buster
	false, # Mod2 / F.Carry
	false, # Mod3 / S.Arrow
]
#endregion
#region Cheat variables
## Infinite ammo.
var infinite_ammo : bool = false
## Ultimate mode.
var ultimate : bool = false
## Free movement / noclip.
var noclip : bool = false
## "Bruiser Brothers" mode: Spawns 2 of every boss.
var bruiser_brothers : bool = false
#endregion
#region References
## Absolute path to player node.
var player : Node # absolute path to player node
## Path to music player node.
@onready var music : Node = $Audio/Music
#endregion
#region Functions
func refill_health() -> void:
	current_hp = max_HP # Reset HP

func refill_ammo() -> void:
	for n in weapon_energy.size():
		weapon_energy[n] = max_WE # Reset WE

func _physics_process(_delta: float) -> void:
	middleroom = ((scrollX1 * 384) + ((scrollX2+1) * 384))/2
	if pausescreen == null and Input.is_action_just_pressed("start") and player != null and inputdisabled == false:
		pausescreen = preload("res://scenes/menus/pause.tscn").instantiate()
		add_child(pausescreen)
		get_tree().paused = true
		freezeframe = false

	if freezedelay > 0:
		freezedelay -= 1
	if freezedelay == 0:
		freezedelay -= 1
		freezeframe = true
		
	if freezeframe == true and freezedelay < 0:
		freezeticks += 1
		if (character_selected == 1 and freezeticks == 15) or freezeticks == 20:
			if !infinite_ammo:
				weapon_energy[WEAPONS.VIDEO] -= 1
			freezeticks = 0
			
	if hit_stop > 0:
		get_tree().paused = true
		hit_stop -= 1
		if hit_stop == 0:
			get_tree().paused = false
		
	if player != null:
		if player.forcebeamed == true:
			damageticks += 1
		if damageticks == 3:
			damageticks = 0
			current_hp -= 1
	
	if bossfightstatus == 4:
		change_music(load("res://audio/music/Stage Completed.wav"))
		bossfightstatus = 5
		
	if bossfightstatus == 6:
		if player != null:
			player.victorydemo = true

func change_music(new_music: AudioStream, new_pitch: float = 1.0, new_volume: float = 0.0) -> void:
	if (music.stream != new_music) or (music.pitch_scale != new_pitch) or (music.volume_db != new_volume) or (continuous_music == false): 
		music.stream = new_music
		music.pitch_scale = new_pitch
		music.volume_db = new_volume
		music.play()

func print_debug_message(msg: String) -> void:
	$Message.text = msg
	$Message.visible = true
	$Message/Timer.start()

func refresh_palette() -> void:
	if palette_selected == 0:
		$PaletteClamp.visible = false
	else:
		$PaletteClamp.visible = true
		$PaletteClamp.material.set_shader_parameter("palette", load(palette_paths[palette_selected]))

func _unhandled_input(event):
	debug_keys(event)
	
func debug_keys(event):
	if (event is InputEventKey) and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if player:
					player.reset(true) # Reset EVERYTHING about the player
					player = null
				get_tree().change_scene_to_file("res://scenes/menus/stage_select.tscn")
				print_debug_message("Exited stage")
			KEY_F1: # Refill health
				refill_health()
				print_debug_message("Refilled health")
			KEY_F2: # Refill ammo
				refill_ammo()
				print_debug_message("Refilled ammo")
			# No F3, because that's our debug info button thanks to that plugin.
			KEY_F4: # Bring current boss down to 1HP
				if bosses.size() > 0:
					if bosses[0]:
						if "Cur_HP" in bosses[0]:
							if bosses[0].Cur_HP > 1:
								bosses[0].Cur_HP = 1
								print_debug_message("Brought boss down to 1 HP")
							else:
								print_debug_message("Boss is already at or below 1 HP")
						else:
							print_debug_message("Boss does not have Cur_HP variable")
					else:
						print_debug_message("No boss in slot 0")
				else:
					print_debug_message("Boss array has size of 0")
			KEY_F5: # Reload the current level.
				if player:
					if player:
						player.reset(true) # Reset EVERYTHING about the player
						player = null
				get_tree().reload_current_scene()
				print_debug_message("Reloaded scene")
			KEY_F6: # Switch characters... despite the character scene only loading upon level load. /shrug
				if character_selected == maxCharacterID: # Last available character, by default Rachel.
					character_selected = 0 # Reset to Maestro.
				else:
					character_selected += 1
				print_debug_message("Changed character to " + char_names[character_selected])
			KEY_F7: # Switch difficulty!!!
				if difficulty == 3: # Very Hard
					difficulty = 0 # Reset to Easy!
				else:
					difficulty += 1 # INCREASE THE DIFFICULTY
				print_debug_message("Changed difficulty to " + diff_names[difficulty])
			# No F8, because that's the button to exit the game.
			KEY_F9: # Toggle noclip / free movement.
				noclip = true if noclip == false else false
			KEY_F10: # Toggle free cam.
				screenmode = 0 if screenmode == -1 else -1
				print_debug_message("Toggled freecam mode")
			KEY_F11: # Toggle fullscreen.
				match DisplayServer.window_get_mode():
					DisplayServer.WINDOW_MODE_WINDOWED:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
					DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					_:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				print_debug_message("Toggled fullscreen mode")
			KEY_F12: # Toggle infinite ammo.
				infinite_ammo = true if infinite_ammo == false else false
				print_debug_message("Toggled infinite ammo")
			KEY_QUOTELEFT: # Swap palette. Replace later with freecam or noclip
				if palette_selected == 12: # Grayscale (16)
					palette_selected = 0 # Reset to None
				else:
					palette_selected += 1 # Change palette
				print_debug_message("Changed palette to " + pal_names[palette_selected])
				refresh_palette()
#endregion

#region Connection functions
func _on_message_timer_timeout() -> void:
	$Message.visible = false
#endregion
