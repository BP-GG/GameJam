extends Node2D

signal tapAtPosition(mouse_position: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_to_idle()

func set_to_idle():
	$Figure.frame = 0
	$Slice.visible = false

func evade_slice_animation():
	var rng = RandomNumberGenerator.new()
	var figure_frame_index = get_new_frame(rng, $Figure.frame, 1, 4)
	var slice_frame_index = get_new_frame(rng, $Slice.frame, 0, 11)
	
	var choice = randi() % 2 == 0
	$Figure.frame = figure_frame_index
	$Figure.flip_h = choice

	$Slice.visible = true
	$Slice.frame = slice_frame_index
	$EvadeTimer.start()

func get_new_frame(rng: RandomNumberGenerator, current_frame: int, range_start: int, range_end: int):
	var new_frame = rng.randi_range(range_start, range_end)
	
	while new_frame == current_frame:
		new_frame = rng.randi_range(range_start, range_end)
	
	return new_frame

func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if event.is_action_pressed("Tap"):
		tapAtPosition.emit(event.position)
		# show_tap_gain_label((event.position - position) * (1 / scale.x))
		evade_slice_animation()

func _on_evade_timer_timeout():
	set_to_idle()

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_ninja_upgrade_unlocked():
	$Figure.animation = "ninja_1"

func _on_ultimate_ninja_upgrade_unlocked():
	$Figure.animation = "ninja_2"