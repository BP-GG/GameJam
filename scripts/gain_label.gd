extends Label

func get_new_position():
	var new_pos = position - Vector2(0, 50)
	var rng = RandomNumberGenerator.new()

	var jitter = rng.randf_range(-20, 20)
	new_pos.x += jitter

	return new_pos

func show_tap_label_animation(value: int):
	text = "+" + str(value)
	$LabelTimer.start()
	var tween = create_tween()	
	var new_pos = get_new_position()
	tween.tween_property(self, "position", new_pos, 1)
	tween.parallel().tween_property(self, "modulate:a", 0, 1.5)

func _on_label_timer_timeout():
	queue_free()