extends Node2D
var event : int = 0
var interval = 5
var vely : float = 1.875

func _ready() -> void:
	await Fade.fade_in().finished
	
func _physics_process(delta):
	if event > interval * 5 + 1  and event < interval * 6-1:
		$MegaMan.position.x -= 1
		
	if event == interval * 8 + 1:
		$MegaMan.position.y -= vely
		vely -= 0.04
		
	if event == interval * 8 + 3:
		if $MegaMan.position.y < 137:
			$MegaMan.position.y -= vely
			vely -= 0.07
		if $MegaMan.position.y >= 137:
			$MegaMan.play("warp")
		
	if $MegaMan.animation == "warp" and $MegaMan.frame == 7:
		$MegaMan.position.y -= 3
		
	
	if $Timer.is_stopped():
		$Timer.start()
		event += 1
		
		if event == interval * 1:
			$BottomCover.play("fadeout")
		if event == interval * 1 + 1:
			$RichTextLabel.visible = false
			$RichTextLabel2.visible = true
			$BottomCover.play("fadein")
			
		if event == interval * 2:
			$BottomCover.play("fadeout")
		if event == interval * 2 + 1:
			$RichTextLabel2.visible = false
			$RichTextLabel3.visible = true
			$BottomCover.play("fadein")
			
		if event == interval * 3:
			$BottomCover.play("fadeout")
		if event == interval * 3 + 1:
			$RichTextLabel3.visible = false
			$RichTextLabel4.visible = true
			$BottomCover.play("fadein")
			
		if event == interval * 4:
			$BottomCover.play("fadeout")
		if event == interval * 4 + 1:
			$RichTextLabel4.visible = false
			$RichTextLabel5.visible = true
			$BottomCover.play("fadein")
			
		if event == interval * 5:
			$BottomCover.play("fadeout")
			$TopCover.play("fadeout")
		if event == interval * 5 + 1:
			$Image.frame += 1
			$RichTextLabel5.visible = false
			$RichTextLabel6.visible = true
			$BottomCover.play("fadein")
			$TopCover.play("fadein")
			
		
			
		if event == interval * 6-1:
			$MegaMan.play("look")
		if event == interval * 6:
			$BottomCover.play("fadeout")
			$TopCover.play("fadeout")
		if event == interval * 6 + 1:
			$Image.frame += 1
			$RichTextLabel6.visible = false
			$RichTextLabel7.visible = true
			$MegaMan.visible = false
			$BottomCover.play("fadein")
			$TopCover.play("fadein")
			
		if event == interval * 6 + 2:
			$TopCover.play("fadeout")
		if event == interval * 6 + 3:
			$Image.frame += 1
			$TopCover.play("fadein")
			
		if event == interval * 6 + 4:
			$TopCover.play("fadeout")
		if event == interval * 6 + 5:
			$Image.frame += 1
			$TopCover.play("fadein")
			
		if event == interval * 6 + 6:
			$TopCover.play("fadeout")
		if event == interval * 6 + 7:
			$Image.frame += 1
			$TopCover.play("fadein")
			
		if event == interval * 6 + 8:
			$BottomCover.play("fadeout")
			$TopCover.play("fadeout")
		if event == interval * 6 + 9:
			$Image.frame = 1
			$RichTextLabel7.visible = false
			$RichTextLabel8.visible = true
			$MegaMan.visible = true
			$BottomCover.play("fadein")
			$TopCover.play("fadein")

		if event == interval * 8:
			$BottomCover.play("fadeout")

		if event == interval * 8 + 1:
			$MegaMan.play("jump")
		
		if event == interval * 8 + 2:
			$MegaMan.play("trans")
			$RichTextLabel8.visible = false
			vely = 0
			
		if event == interval * 8 + 5:
			$TopCover.play("fadeout")
			
		if event == interval * 9:
			$Image.visible = false
			$TopCover.play("fadein")
			
		if event == interval * 10:
			$TopCover.play("fadeout")
		if event == interval * 10 + 1:
			$Image.visible = true
			$Image.frame = 6
			$TopCover.play("fadein")
			$BottomCover.play("fadein")
			$RichTextLabel9.visible = true
			
		if event == interval * 11:
			$BottomCover.play("fadeout")
		if event == interval * 11 + 1:
			$BottomCover.play("fadein")
			$RichTextLabel9.visible = false
			$RichTextLabel10.visible = true
			
		if event == interval * 12:
			$BottomCover.play("fadeout")
		if event == interval * 12 + 1:
			$BottomCover.play("fadein")
			$RichTextLabel10.visible = false
			$RichTextLabel11.visible = true
			
		if event == interval * 12:
			$TopCover.play("fadeout")
			$BottomCover.play("fadeout")
		if event == interval * 12 + 1:
			$TopCover.play("fadein")
			$BottomCover.play("fadein")
			$Image.frame = 7
			$RichTextLabel11.visible = false
			$RichTextLabel12.visible = true
			
		
			
