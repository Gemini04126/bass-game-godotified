class_name Pause_Screen extends CanvasLayer
var pause : bool = false

var BWEAPONS = [
	"A rapid-fire 
	weapon that 
	can be aimed.",
	
	"Shield that
	blocks shots
	and damages
	enemies.",
	
	"Stops time.
	You can use
	your buster
	while in use.",
	
	"Seeks out
	and disables
	enemies.",
	
	"Very strong,
	but can only
	be used on the
	ground.",
	
	"5-bullet
	spread shot.
	Great at
	close range.",
	
	"Blows away
	enemies.
	Limited uses",
	
	"Rolls on
	any surface.
	Explodes to
	do heavy dmg.",
	
	"Boomerangs
	that can be
	charged and
	aimed up/dwn.",
	
	"Very strong
	buster that
	can charge
	its shots.",
	
	"TREBLE.A"
]

var BMODS = [
	"MACHBUST.",
	
	"Upwards dash
	in the air
	+ downwards 
	attack.",
	
	"A copy that
	keeps firing.
	redirect w/
	buster btn.",
	
	"Invincible
	dash that can
	go through
	small gaps.",
	
	"Take less
	DMG and can
	swim in water.",
	
	"A melee atk
	that goes
	through some
	shields.",
	
	"Glide in
	the air for
	a short time.",
	
	"Buster is
	powered up.
	Charges up 5
	shots idly.",
	
	"An aerial dash
	that ignores
	gravity.",
	
	"Blocks enemy
	shots from the
	front.",
	
	"TREBLE.A"
]

var CWEAPONS = [
	"P.BUSTER",
	"Shield that
	blocks shots
	and damages
	enemies.",
	
	"Stops time.
	You can use
	your buster
	while in use.",
	
	"Seeks out
	and disables
	enemies.",
	
	"Can only be 
	used on ground.
	Charge for a
	double attack!",
	
	"5-bullet
	spread shot.
	Great at
	close range.",
	
	"Blows away
	enemies.
	Limited uses",
	
	"Rolls on
	any surface.
	Explodes to
	do heavy dmg.",
	
	"Boomerangs
	that can be
	charged and
	aimed up/dwn.",
	
	"Blocks shots
	from your
	front",
	
	"TREBLE.A",
	
	"Creates a
	platform in
	front of or
	under you.",
	
	"An arrow
	you can ride
	on top of.",
	
	"MIRROR B.",
	
	"Arcing blade.
	Can be thrown
	rapidly.",
	
	"Powerful
	explosive.
	can be aimed.",
	
	"SAKUGARNE"
]

var MWEAPONS = [
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

var RWEAPONS = [
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

func _ready():
	if GameState.character_selected != 1:
		$BassWeps.queue_free()
	if GameState.character_selected != 2 and GameState.character_selected != 0:
		$CopyWeps.queue_free()
	if GameState.character_selected != 3:
		$MegaWeps.queue_free()
	if GameState.character_selected != 4:
		$ProtoWeps.queue_free()
	if GameState.character_selected != 5:
		$RachelWeps.queue_free()
		
	$TileMapLayer.visible = false
	$Sprite2D.visible = false
	$WeaponDesc.visible = false
	await $FadeFG.animation_finished
	
	match GameState.character_selected:
		0:
			$CopyWeps.process_mode = PROCESS_MODE_ALWAYS
			$CopyWeps.visible = true
		1:
			$BassWeps.process_mode = PROCESS_MODE_ALWAYS
			$BassWeps.visible = true
		2:
			$CopyWeps.process_mode = PROCESS_MODE_ALWAYS
			$CopyWeps.visible = true
		3:
			$MegaWeps.process_mode = PROCESS_MODE_ALWAYS
			$MegaWeps.visible = true
		4:
			$ProtoWeps.process_mode = PROCESS_MODE_ALWAYS
			$ProtoWeps.visible = true
		5:
			$RachelWeps.process_mode = PROCESS_MODE_ALWAYS
			$RachelWeps.visible = true
	
	
	
	
	$Sprite2D.texture = GameState.player.get_node("Sprite2D").texture
	$WeaponDesc.visible = true
		
	$TileMapLayer.visible = true
	$Sprite2D.visible = true
	$FadeFG.play("fadeout")
	
func _process(_delta):
	if GameState.character_selected == 1:
		if (GameState.modules_enabled[GameState.paused_weapon] == true and GameState.paused_weapon != 0) or (GameState.paused_weapon == 0 and GameState.modules_enabled[GameState.WEAPONS.GUERRILLA] == true):
			$WeaponDesc.text = "%s" % BMODS[GameState.paused_weapon]
		else:
			$WeaponDesc.text = "%s" % BWEAPONS[GameState.paused_weapon]
	if GameState.character_selected == 2 or GameState.character_selected == 0:
		$WeaponDesc.text = "%s" % CWEAPONS[GameState.paused_weapon]
	if GameState.character_selected == 3:
		$WeaponDesc.text = "%s" % MWEAPONS[GameState.paused_weapon]
	if GameState.character_selected == 4:
		$WeaponDesc.text = "%s" % PWEAPONS[GameState.paused_weapon]
	if GameState.character_selected == 5:
		$WeaponDesc.text = "%s" % RWEAPONS[GameState.paused_weapon]
	
	$Sprite2D.material.set_shader_parameter("palette", GameState.player.get_node("Sprite2D").material.get_shader_parameter("palette"))
	if $TransTimer.is_stopped() and pause != true:
		get_tree().paused = true
		pause = true
		
	if Input.is_action_just_pressed("start") and $TransTimer.is_stopped():
		$FadeFG.play("fadein")
		await $FadeFG.animation_finished
		
		if GameState.character_selected == 1:
			$BassWeps.queue_free()
		if GameState.character_selected == 2 or GameState.character_selected == 0:
			$CopyWeps.queue_free()
		if GameState.character_selected == 3:
			$MegaWeps.queue_free()
		if GameState.character_selected == 4:
			$ProtoWeps.queue_free()
		if GameState.character_selected == 5:
			$RachelWeps.queue_free()
			
		$Sprite2D.visible = false
		$WeaponDesc.visible = false
		
		$FadeBG.play("fadeout")
		$FadeFG.play("fadeout")
		$TileMapLayer.queue_free()
		get_tree().paused = false
		await $FadeBG.animation_finished
		queue_free()
		
	
	

func _on_item_list_item_selected(index):
	GameState.character_selected = index


func _on_item_list_2_item_selected(index):
	GameState.difficulty = index
