extends CanvasLayer

var current_points = NumberValue.new()

func set_current_points(val: int):
	current_points.set_value(val)
	$ResistancePoints/Label.text = current_points.show()
