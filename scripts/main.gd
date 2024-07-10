extends Node2D

var gain_label = preload("res://scenes/gain_label.tscn")
var number_of_riots = 0
var points = 0

func _on_character_tap_at_position(mouse_position: Vector2):
	var label = gain_label.instantiate()
	label.position = Vector2(mouse_position.x, mouse_position.y - 30)
	add_child(label)
	
	var val = 1
	label.show_tap_label_animation(val)
	points += val
	$InventoryHUD.set_points_label(points)
	$UpgradesHUD.set_points(points)

func _on_upgrades_hud_update_points(new_points: int):
	points = new_points
	$InventoryHUD.set_points_label(points)

func _on_new_riot_created():
	number_of_riots += 1
	$Earth.add_riot()
