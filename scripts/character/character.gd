extends Node2D


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

	$Figure.frame = figure_frame_index

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
		evade_slice_animation()

func _on_evade_timer_timeout():
	set_to_idle()
