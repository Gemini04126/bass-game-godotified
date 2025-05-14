@tool
class_name SteelBlock
extends StaticBody2D

var Dmg_Vals : Array[int]


const styles = [
	"Test",
	"Blaze",
	"Video",
	"Smog",
	"Shark",
	"Origami",
	"Gale",
	"Guerrilla",
	"Reaper"
]
func _ready():
	Dmg_Vals.resize(GameState.DMGTYPE.size())
	Dmg_Vals[GameState.DMGTYPE.CB_SMOG] = 0
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_1] = 3
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_2] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_GALE] = 0
	Dmg_Vals[GameState.DMGTYPE.CB_ORIGAMI] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_GUERILLA] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_1] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_2] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_3] = 3
	
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_1] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_2] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_3] = 3
	Dmg_Vals[GameState.DMGTYPE.CR_BLAZE] = 0
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK1] = 3
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK2] = 3
	Dmg_Vals[GameState.DMGTYPE.CR_ARROW] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_ENKER] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_PUNK] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BALLADE] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT1] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT2] = 2
	
	Dmg_Vals[GameState.DMGTYPE.BS_BUSTER] = 2
	Dmg_Vals[GameState.DMGTYPE.BS_BLAZE] = 0
	Dmg_Vals[GameState.DMGTYPE.BS_SHARK] = 3
	Dmg_Vals[GameState.DMGTYPE.BS_TREBLE] = 2
	
	Dmg_Vals[GameState.DMGTYPE.MD_BLAZE] = 2
	Dmg_Vals[GameState.DMGTYPE.MD_VIDEO] = 2
	Dmg_Vals[GameState.DMGTYPE.MD_ORIGAMI] = 3
	Dmg_Vals[GameState.DMGTYPE.MD_GUERILLA] = 2
	Dmg_Vals[GameState.DMGTYPE.MD_GUERILLA2] = 2
	
	Dmg_Vals[GameState.DMGTYPE.RA_BUSTER] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_GALAXY] = 3
	Dmg_Vals[GameState.DMGTYPE.RA_TOP] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_GEMINI] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_GRENADE] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_YAMATO] = 3
	Dmg_Vals[GameState.DMGTYPE.RA_MAGMA] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_MAGMA2] = 3
	Dmg_Vals[GameState.DMGTYPE.RA_PHARAOH] = 3
	Dmg_Vals[GameState.DMGTYPE.RA_CHILL] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_CHILL2] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_WIRE] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_TERRA] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_MERCURY] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_MARS] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_PLUTO] = 3 # yeah fuck you i'm stronger 💪😤
	Dmg_Vals[GameState.DMGTYPE.RA_ROSE] = 2 # Maybe?
	
	$AnimatedSprite2D.play(styles[style])

var _style : int = 0
## Breakable Block sprite set to display
@export_enum ("Test", "Blaze", "Video", "Smog", "Shark", "Origami", "Gale", "Guerrilla", "Reaper") var style : int :
	get:
		return _style
	set(value):
		_style = value;
		$AnimatedSprite2D.play(styles[style])

	

func _on_hitable_body_entered(weapon):
	if Dmg_Vals[weapon.W_Type] == 0: #no interaction
		weapon.reflect()
	else:
		if Dmg_Vals[weapon.W_Type] == 1: #reflects off but still kills
			weapon.reflect()
		if Dmg_Vals[weapon.W_Type] == 2: #breaks one block
			weapon.destroy()
		if Dmg_Vals[weapon.W_Type] == 3: #goes right through
			weapon.kill()
		
		$Collision.queue_free()
		$hitable.queue_free()
		$AnimatedSprite2D.play("Explode")
		await $AnimatedSprite2D.animation_finished
		queue_free()
