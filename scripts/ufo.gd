extends Node2D

var delay: int = 0.5
var init_position: Vector2

func _ready():
	init_position = position

func _on_character_enter_idle():
	var tween = create_tween()
	tween.tween_property($Target_Animation, "position", Vector2(0, 0), 0.5)
	tween.tween_callback(show_UFO).set_delay(0.5)

func show_UFO():
	$Node2D/Sprite2D.visible = true

	$AnimationPlayer.queue("fade_out_target")
	$EntranceAnimations.queue("ufo_enter")
	$AnimationPlayer.queue("ufo_idle")

func _on_character_leave_idle():
	var tween = create_tween()
	tween.tween_callback(hide_UFO).set_delay(0.5)

func hide_UFO():
	$Target_Animation.visible = true
	$EntranceAnimations.queue("ufo_leave")	
	$AnimationPlayer.play("fade_in_target")

func show_target_animation():
	$Target_Animation.play("target_locked")

func move_target_position(pos: Vector2, speed: float):
	var tween = create_tween()
	tween.tween_property($Target_Animation, "position", pos, 0.3 / speed)

