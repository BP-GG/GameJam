extends Node2D

var gain_label = preload("res://scenes/gain_label.tscn")
var number_of_riots = 0
var points = 0
var total_points = 0
var tap_multiplier = 1
var additive_multiplier = 0

var next_points_threshold: float = 1e3

var purchased_upgrades: Array[TextureButton] = []
var purchased_structures: Array[TextureButton] = []

func _ready():
	var tween = create_tween()
	tween.tween_property(self,"modulate:a", 1, 1)

func _on_character_tap_at_position(mouse_position: Vector2):
	var label = gain_label.instantiate()
	label.position = Vector2(mouse_position.x, mouse_position.y - 30)
	add_child(label)
	
	var val = tap_multiplier + additive_multiplier
	label.show_tap_label_animation(val)
	points += val
	total_points += val
	$InventoryHUD.set_current_points(points)
	$UpgradesHUD.set_points(points)
	$UpgradesHUD.update_structure_unlock_status(total_points)

func _on_upgrades_hud_update_points(new_points: int):
	points = new_points
	$InventoryHUD.set_current_points(points)

func _on_increase_total_points(value: int):
	total_points += value
	$UpgradesHUD.update_structure_unlock_status(total_points)

func _on_new_riot_created():
	number_of_riots += 1
	$Earth.add_riot()

func update_additive_multiplier(new_value: float):
	additive_multiplier = new_value

func _on_structure_purchased(structure: TextureButton):
	if structure.structure_name.to_lower() == "riot":
		_on_new_riot_created()

	if structure not in purchased_structures:
		purchased_structures.append(structure)
	
	$MessageMenu._on_structure_purchased(structure)

func _on_upgrade_purchased(upgrade: TextureButton):
	purchased_upgrades.append(upgrade)

	# Check if purchased update is a tap upgrade
	# These updates have upgrade_type_id 0, and are not associated with a structure (they upgrade the tap efficiency)
	if upgrade.upgrade_type_id == 0:
		upgrade.connect("additiveMultiplier", update_additive_multiplier)
		tap_multiplier *= upgrade.production_rate_multiplier

		# Ninja upgrade unlocked
		if upgrade.upgrade_level == 2:
			$Character._on_ninja_upgrade_unlocked()
		
		# Ultimate Ninja upgrade unlocked
		if upgrade.upgrade_level == 3:
			$Character._on_ultimate_ninja_upgrade_unlocked()
	
	$MessageMenu._on_upgrade_purchased(upgrade)

func _on_total_points_increased():
	if total_points >= next_points_threshold:
		$MessageMenu._on_total_points_threshold_reached(total_points)
		next_points_threshold = next_points_threshold * 1000

func _on_counter_attack_unlocked():
	$MessageMenu._on_counter_attack_ready()
	$Earth._on_counter_attack_ready()

func _on_counter_attack_purchased():
	get_tree().change_scene_to_file("res://scenes/final_scene.tscn")