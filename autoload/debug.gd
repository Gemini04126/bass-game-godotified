extends Node
func _unhandled_input(event):
	if (event is InputEventKey) and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if GameState.player:
					GameState.player.reset(true) # Reset EVERYTHING about the player
					GameState.player = null
				get_tree().change_scene_to_file("res://scenes/menus/stage_select.tscn")
			KEY_F1: # Refill health
				GameState.refill_health()
			KEY_F2: # Refill ammo
				GameState.refill_ammo()
			# No F3, because that's our debug info button thanks to that plugin.
			#KEY_F4: # Kill current boss or bring him down to 1HP
			KEY_F5: # Reload the current level.
				if GameState.player:
					if GameState.player:
						GameState.player.reset(true) # Reset EVERYTHING about the player
						GameState.player = null
				get_tree().reload_current_scene()
			KEY_F6: # Switch characters... despite the character scene only loading upon level load. /shrug
				match GameState.character_selected:
					GameState.maxCharacterID: # Last available character, by default Mega Man.
						GameState.character_selected = 0 # Reset to Maestro.
					_:
						GameState.character_selected += 1
			KEY_F7: # Switch difficulty!!!
				match GameState.difficulty:
					4: #Very Hard
						GameState.difficulty = 0 # Reset to Easy!
					_:
						GameState.difficulty += 1 #INCREASE THE DIFFICULTY
				print(GameState.difficulty)
			# No F8, because that's the button to exit the game.
			#KEY_F9:
			#KEY_F10:
			KEY_F11:
				match DisplayServer.window_get_mode():
					DisplayServer.WINDOW_MODE_WINDOWED:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
					DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					_:
						DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			KEY_F12: # Toggle infinite ammo
				if GameState.infinite_ammo == false:
					GameState.infinite_ammo = true
				else:
					GameState.infinite_ammo = false
