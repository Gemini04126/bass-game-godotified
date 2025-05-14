@tool
class_name BreakableBlock
extends StaticBody2D

var Dmg_Vals : Array[int]
var Cur_HP : int = 3
var subtype : int

func basedmg():
	Dmg_Vals.resize(GameState.DMGTYPE.size())
	
	Dmg_Vals[GameState.DMGTYPE.CB_SMOG] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_1] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_REAPER_2] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_GALE] = 0
	Dmg_Vals[GameState.DMGTYPE.CB_ORIGAMI] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_GUERILLA] = 2
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_1] = 1
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_2] = 3
	Dmg_Vals[GameState.DMGTYPE.CB_PROTO_3] = 4
	
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_1] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_2] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BUSTER_3] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_BLAZE] = 0.75
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK1] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_SHARK2] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_ARROW] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_ENKER] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_PUNK] = 2
	Dmg_Vals[GameState.DMGTYPE.CR_BALLADE] = 4
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT1] = 1
	Dmg_Vals[GameState.DMGTYPE.CR_QUINT2] = 1
	
	Dmg_Vals[GameState.DMGTYPE.BS_BUSTER] = 1
	Dmg_Vals[GameState.DMGTYPE.BS_BLAZE] = 0.75
	Dmg_Vals[GameState.DMGTYPE.BS_SHARK] = 4
	Dmg_Vals[GameState.DMGTYPE.BS_TREBLE] = 1
	
	Dmg_Vals[GameState.DMGTYPE.MD_BLAZE] = 2
	Dmg_Vals[GameState.DMGTYPE.MD_VIDEO] = 1
	Dmg_Vals[GameState.DMGTYPE.MD_ORIGAMI] = 4
	Dmg_Vals[GameState.DMGTYPE.MD_GUERILLA] = 2
	
	Dmg_Vals[GameState.DMGTYPE.RA_BUSTER] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_GALAXY] = 3
	Dmg_Vals[GameState.DMGTYPE.RA_TOP] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_GEMINI] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_GRENADE] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_YAMATO] = 2
	Dmg_Vals[GameState.DMGTYPE.RA_MAGMA] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_MAGMA2] = 4
	Dmg_Vals[GameState.DMGTYPE.RA_PHARAOH] = 4
	Dmg_Vals[GameState.DMGTYPE.RA_CHILL] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_CHILL2] = 1
	Dmg_Vals[GameState.DMGTYPE.RA_WIRE] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_TERRA] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_MERCURY] = 0
	Dmg_Vals[GameState.DMGTYPE.RA_MARS] = 4
	Dmg_Vals[GameState.DMGTYPE.RA_PLUTO] = 4
	Dmg_Vals[GameState.DMGTYPE.RA_ROSE] = 2
	
func _ready():
	basedmg()

func _on_hitable_body_entered(weapon):
	Cur_HP -= Dmg_Vals[weapon.W_Type]
	
	
	if Dmg_Vals[weapon.W_Type] == 0:	
		weapon.reflect()
		#Cool, it does damage!!
	else:
		if (weapon.W_Type == GameState.DMGTYPE.BS_SHARK or weapon.W_Type == GameState.DMGTYPE.CR_SHARK1 or weapon.W_Type == GameState.DMGTYPE.CR_SHARK2):
			weapon.kill()
		else:
			weapon.destroy()
		#Is it Scorch Barrier?
		if weapon.is_in_group("scorch"):
			weapon.durability -= 3
		#Look up the damage type and do damage according to it.
		if Cur_HP <= 0:	
			$Collision.queue_free()
			$hitable.queue_free()
			$AnimatedSprite2D.play("Explode")
			await $AnimatedSprite2D.animation_finished
			queue_free()
		else:
			#Clean this up later
			if Cur_HP == 1:
				$AnimatedSprite2D.play("1")
			if Cur_HP == 2:
				$AnimatedSprite2D.play("2")
			if Cur_HP == 3:
				$AnimatedSprite2D.play("3")
			
