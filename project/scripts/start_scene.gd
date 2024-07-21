extends Node2D

var main_scene = preload("res://scenes/main.tscn")
var music_on = false

func _on_start_game_pressed():
	var tween = create_tween()
	tween.tween_property(self,"modulate:a", 0, 1)
	get_tree().change_scene_to_packed(main_scene)

func _on_texture_button_pressed():
	if not music_on:
		$AudioStreamPlayer.play()
		music_on = true
	else:
		$AudioStreamPlayer.stop()
		music_on = false
	
	_change_music_button_icon()

func _change_music_button_icon():
	if not music_on:
		$TextureButton.set_texture_normal("res://assets/mute.svg")
	else:
		$TextureButton.set_texture_normal("res://assets/play.svg")
