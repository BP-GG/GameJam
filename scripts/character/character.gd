extends Node2D

signal tapAtPosition(mouse_position: Vector2)

enum CharacterModel {REGULAR, NINJA, ULTIMATE_NINJA}

# 1 uses regular character model, 2 uses ninja model, 3 uses ultimate ninja
var character_model: CharacterModel = CharacterModel.ULTIMATE_NINJA
var enter_idle: bool = true
var is_in_idle: bool = false

var last_frame = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	play_enter_idle_animation()
	$EvadeTimer.start()
	$UFO.visible = true

func _process(_delta):
	if not character_model == CharacterModel.REGULAR and not is_in_idle:
		$UFO.move_target_position($Figure/Hitbox.position, $AnimationPlayer.speed_scale)

func regular_evade_slice_animation():
	$Figure.animation = "default"
	$Figure.stop()
	var rng = RandomNumberGenerator.new()
	var figure_frame_index = get_new_animation_value(rng, last_frame, 1, 4)
	
	$Figure.frame = figure_frame_index
	$Figure.flip_h = false
	last_frame = figure_frame_index

func play_slice_animation():
	var rng = RandomNumberGenerator.new()
	var slice_frame_index = get_new_animation_value(rng, $Slice.frame, 0, 11)
	var choice_x = randi() % 2 == 0
	var choice_y = randi() % 2 == 0

	$Slice.frame = slice_frame_index
	$Slice.flip_h = choice_x
	$Slice.flip_v = choice_y

func get_new_animation_value(rng: RandomNumberGenerator, current_animation: int, range_start: int, range_end: int):
	var new_animation = rng.randi_range(range_start, range_end)
	
	while new_animation == current_animation:
		new_animation = rng.randi_range(range_start, range_end)
	
	return new_animation

func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event.is_action_pressed("Tap"):
		tapAtPosition.emit(event.position)
		enter_idle = false
		$AnimationPlayer.speed_scale += 0.01
		$EvadeTimer.start()
		$TapDecayTimer.start()

		play_slice_animation()
		if (character_model == CharacterModel.REGULAR and not $AnimationPlayer.is_playing()):
			regular_evade_slice_animation()
			$RegularIdleCooldownTimer.start()

		if is_in_idle and not $AnimationPlayer.is_playing():
			play_leave_idle_animation()


func play_enter_idle_animation():
	$AnimationPlayer.speed_scale = 1
	if character_model == CharacterModel.REGULAR:
		$AnimationPlayer.play("regular_idle")
	elif character_model == CharacterModel.NINJA:
		$AnimationPlayer.play("ninja_idle")
		$UFO._on_character_enter_idle()
	elif  character_model == CharacterModel.ULTIMATE_NINJA:
		$AnimationPlayer.play("ultimate_ninja_idle")
		$UFO._on_character_enter_idle()

	is_in_idle = true

func play_leave_idle_animation():
	$AnimationPlayer.speed_scale = 1

	if character_model == CharacterModel.REGULAR:
		$AnimationPlayer.play("regular_leave_idle")
	
	elif character_model == CharacterModel.NINJA:
		$AnimationPlayer.play("ninja_leave_idle")
		$UFO._on_character_leave_idle()

	elif  character_model == CharacterModel.ULTIMATE_NINJA:
		$AnimationPlayer.play("ultimate_ninja_leave_idle")
		$UFO._on_character_leave_idle()

	is_in_idle = false

func play_tap_animation():
	if character_model == CharacterModel.REGULAR:
		regular_evade_slice_animation()
	else:
		var rng = RandomNumberGenerator.new()
		var animation_number = rng.randi_range(1, 3)
		$Figure.flip_h = false
		$AnimationPlayer.play("ninja_evade_" + str(animation_number))
	
func _on_evade_timer_timeout():
	enter_idle = true

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_ninja_upgrade_unlocked():
	character_model = CharacterModel.NINJA
	enter_idle = true
	$AnimationPlayer.play("ninja_idle")
	$UFO.visible = true
	$UFO._on_character_enter_idle()

func _on_ultimate_ninja_upgrade_unlocked():
	character_model = CharacterModel.ULTIMATE_NINJA
	enter_idle = true
	$AnimationPlayer.play("ultimate_ninja_idle")
	$UFO._on_character_enter_idle()

func _on_character_animation_finished(anim_name: String):
	if enter_idle and anim_name == "regular_idle":
		play_shield_recoil_animation()
	elif not enter_idle and is_shield_recoil_animation(anim_name):
		play_leave_idle_animation()

	elif enter_idle and is_shield_recoil_animation(anim_name):
		play_shield_recoil_animation()

	elif character_model == CharacterModel.REGULAR and anim_name == "regular_leave_idle":
		$RegularIdleCooldownTimer.start()
		$Slice.visible = true

	# If flag is true but character is already idle, just reset the enter idle flag
	elif enter_idle and is_in_idle:
		enter_idle = false

	# Otherwise, if the flag is true but character isn't in idle, play the enter idle animation
	elif enter_idle:
		play_enter_idle_animation()
	
	# If the flag is false, but the character is in idle, we need to leave the idle animation (play transition animation)
	elif is_in_idle:
		play_leave_idle_animation()
	
	# Otherwise continue playing the evasion animation
	else:
		play_tap_animation()

func play_shield_recoil_animation():
	var rng = RandomNumberGenerator.new()
	var index = rng.randi_range(1, 4)
	var animation = "shield_recoil_" + str(index)

	var choice = randi() % 2 == 0
	$Figure.flip_h = choice

	$AnimationPlayer.play(animation)

func is_shield_recoil_animation(animation: String):
	return animation.begins_with("shield_recoil")

func _on_tap_decay_timer_timeout():
	$AnimationPlayer.speed_scale = max(1, $AnimationPlayer.speed_scale - 0.1)

func _on_regular_idle_cooldown_timer_timeout():
	enter_idle = true
	if character_model == CharacterModel.REGULAR and not $AnimationPlayer.is_playing():
		$Slice.visible = false
		_on_character_animation_finished("default")
