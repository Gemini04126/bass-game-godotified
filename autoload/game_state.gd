extends CanvasLayer

@onready var projectile

#region Enums
enum WEAPONS {BUSTER, BLAZE, VIDEO, SMOG, SHARK, ORIGAMI, GALE, GUERRILLA, REAPER, PROTO, TREBLE, CARRY, ARROW, ENKER, PUNK, BALLADE, QUINT}
enum PALETTE {NONE, MD, NES, DOOM, PICO8, GB, VB, C64, CGA, G4, G8, G16}
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

#region Variables
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

var stage_action : int
var stage_boss_weapon : int
var stage_progress_update : String = ""
var dialogue_open: bool = false

var maxCharacterID = characters.size() - 1 # Whyyyyy...?
var character_selected : int
var player # absolute path to player node
var player_lives : int = 3
var bossfightstatus : int = 0
# 0: No fight.
# 1: Intro
# 2: FIGHT!
# 3: You win!
var bossestokill : int = 0

## Currently playing music. 0: None. 1: Stage. 2: Boss. 3: Fortress Boss.
var musicplaying : int = 0 

var pausescreen
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
var infinite_ammo : bool = false
var ultimate : bool = false
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
				GameState.weapon_energy[GameState.WEAPONS.VIDEO] -= 1
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
	
	if musicplaying == 2:
		if $Music/BossMusic.get_stream_playback() == null:
			$Music/BossMusic.play()
		if freezeframe == true:
			$Music/BossMusic.stream_paused = true
		else:
			$Music/BossMusic.stream_paused = false
	elif musicplaying != 2:
		$Music/BossMusic.stop()
	
	if musicplaying == 3:
		if $Music/FortBossMusic.get_stream_playback() == null:
			$Music/FortBossMusic.play()
		if freezeframe == true:
			$Music/FortBossMusic.stream_paused = true
		else:
			$Music/FortBossMusic.stream_paused = false
	else:
		$Music/FortBossMusic.stop()
	
	if musicplaying == 4:
		if $Music/WilyBossMusic.get_stream_playback() == null:
			$Music/WilyBossMusic.play()
		if freezeframe == true:
			$Music/WilyBossMusic.stream_paused = true
		else:
			$Music/WilyBossMusic.stream_paused = false
	else:
		$Music/WilyBossMusic.stop()
			
	if bossfightstatus == 4:
		$Music/StageComplete.play()
		bossfightstatus = 5
		
	if bossfightstatus == 6:
		if player != null:
			player.victorydemo = true
	
