extends Node2D
var event : int = 0
var interval = 5
func _ready() -> void:
	await Fade.fade_in().finished
	
func _physics_process(delta):
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
			
		if event == interval * 6:
			$BottomCover.play("fadeout")
			$TopCover.play("fadeout")
		if event == interval * 6 + 1:
			$Image.frame += 1
			$RichTextLabel6.visible = false
			$RichTextLabel7.visible = true
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
			$BottomCover.play("fadein")
			$TopCover.play("fadein")
			
		if event == interval * 8:
			$BottomCover.play("fadeout")
			$TopCover.play("fadeout")
		if event == interval * 8 + 1:
			$Image.frame = 1
			$RichTextLabel7.visible = false
			$RichTextLabel8.visible = true
			$BottomCover.play("fadein")
			$TopCover.play("fadein")
