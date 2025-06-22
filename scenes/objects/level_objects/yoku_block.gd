@tool

class_name YokuBlock
extends StaticBody2D
var time : float

static var static_audio_player : AudioStreamPlayer2D
const styles = [
	"res://sprites/objects/yoku_blocks/Test.png",
	"res://sprites/objects/yoku_blocks/Blaze.png",
	"res://sprites/objects/yoku_blocks/Video.png",
	"res://sprites/objects/yoku_blocks/Smog.png",
	"res://sprites/objects/yoku_blocks/Shark.png",
	"res://sprites/objects/yoku_blocks/Origami.png",
	"res://sprites/objects/yoku_blocks/Gale.png",
	"res://sprites/objects/yoku_blocks/Guerrilla.png",
	"res://sprites/objects/yoku_blocks/Reaper.png",
	"res://sprites/objects/yoku_blocks/Enker.png"
]

var _style : int = 0
## Yoku Block sprite set to display
var style : int :
	get:
		return _style
	set(value):
		if (value < styles.size()) && (value >= 0):
			_style = value;
			$Sprite2D.texture = load(styles[_style])

var state : bool = false # Off (in)

func _ready():
	style = get_parent().style
	if !static_audio_player:
		static_audio_player = $YokuSound
	$Sprite2D.texture = load(styles[_style])
	$AnimationPlayer.play("RESET")
	
func _physics_process(_delta: float):
		if $RayCast2D.is_colliding():
			$Shadow.visible = false
		else:
			$Shadow.visible = true
		if not Engine.is_editor_hint():
			if GameState.freezeframe == true:
				$AnimationPlayer.process_mode = Node.PROCESS_MODE_DISABLED
				$YokuSound.process_mode = Node.PROCESS_MODE_DISABLED
				$Timer.process_mode = Node.PROCESS_MODE_DISABLED
			else:
				$AnimationPlayer.process_mode = Node.PROCESS_MODE_INHERIT
				$YokuSound.process_mode = Node.PROCESS_MODE_INHERIT
				$Timer.process_mode = Node.PROCESS_MODE_INHERIT
			
		if get_parent().interval == get_parent().get_parent().interval and $Timer.is_stopped():
			$AnimationPlayer.play("appear")
			$Timer.start(get_parent().duration)
			if not Engine.is_editor_hint():
				var players = get_tree().get_nodes_in_group("player")
				if static_audio_player && players.size() >= 1:
					if position.distance_to(players[0].position) < 216:
						static_audio_player.play()
			

func _on_timer_timeout() -> void:
	$AnimationPlayer.play("disappear")
