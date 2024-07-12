extends Node2D

var gain_label = preload("res://scenes/gain_label.tscn")
var number_of_riots = 0
var points = 0
var total_points = 0
var tap_multiplier = 1

var purchased_upgrades: Array[TextureButton] = []

func _on_character_tap_at_position(mouse_position: Vector2):
	var label = gain_label.instantiate()
	label.position = Vector2(mouse_position.x, mouse_position.y - 30)
	add_child(label)
	
	var val = tap_multiplier
	label.show_tap_label_animation(val)
	points += val
	total_points += val
	$InventoryHUD.set_points_label(points)
	$UpgradesHUD.set_points(points)

func _on_upgrades_hud_update_points(new_points: int):
	points = new_points
	$InventoryHUD.set_points_label(points)

func _on_increase_total_points(value: int):
	total_points += value

func _on_new_riot_created():
	number_of_riots += 1
	$Earth.add_riot()

func _on_upgrade_purchased(upgrade: TextureButton):
	purchased_upgrades.append(upgrade)

	# Check if purchased update is a tap upgrade
	# These updates have upgrade_type_id 0, and are not associated with a structure (they upgrade the tap efficiency)
	if upgrade.upgrade_type_id == 0:
		tap_multiplier *= upgrade.production_rate_multiplier

		# Ninja upgrade unlocked
		if upgrade.upgrade_level == 2:
			$Character._on_ninja_upgrade_unlocked()
		
		# Ultimate Ninja upgrade unlocked
		if upgrade.upgrade_level == 3:
			$Character._on_ultimate_ninja_upgrade_unlocked()