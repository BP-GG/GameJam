extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():

	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0, 1)
	tween.chain()
	tween.tween_property($ColorRect, "modulate:a", 0.8, 1)
	tween.parallel()
	tween.tween_property($Label, "modulate:a", 1, 1)
