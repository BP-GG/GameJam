extends CanvasLayer

signal updatePoints(points)
signal upgradePurchased(upgrade)
signal structurePurchased(structure)
signal increaseTotalPoints(points)
signal counterAttackAvailable
signal counterAttackPurchased

var points = 0

var structure_btn = preload("res://scenes/upgrades/structure_button.tscn")
var upgrade_btn = preload("res://scenes/upgrades/upgrade_button.tscn")

var structures: Array[TextureButton] = []
var upgrades = []

var counter_attack: TextureButton 

func _ready():

	# Load the structure (building) data
	var structure_db = TextDatabase.new()
	structure_db.load_from_path("res://data/structures.cfg")
	var structure_data = structure_db.get_dictionary().values()

	# Add the data as buttons in the Resistances Menu of the HUD
	for i in range(structure_data.size()):

		# Add child instance
		var structure_instance = structure_btn.instantiate()
		structure_instance.set_values(structure_data[i])
		$StructureContainer/StructureMenu.add_child(structure_instance)
		structures.append(structure_instance)

		# Adjust position and add vertical padding (pad = 34)
		structure_instance.position.x = -300
		structure_instance.position.y = -402 + i * (structure_instance.size.y + 34) 

	var upgrade_db = TextDatabase.new()
	upgrade_db.load_from_path("res://data/upgrades.cfg")
	var upgrade_data = upgrade_db.get_dictionary().values()

	# Add the data as buttons in the Upgrades Menu of the HUD
	for i in range(upgrade_data.size()):

		# Add child instance
		var upgrade_instance = upgrade_btn.instantiate()
		upgrade_instance.set_values(upgrade_data[i], structures.size())
		$UpgradeContainer/UpgradesMenu.add_child(upgrade_instance)
		upgrades.append(upgrade_instance)
	
	instantiate_counter_attack_upgrade()
	
	connect_signals()
	show_structures_menu()

func instantiate_counter_attack_upgrade():
	var counter_attack_scene = preload("res://scenes/upgrades/counter_attack.tscn")
	var counter_attack_instance = counter_attack_scene.instantiate()
	counter_attack_instance.required_number_of_upgrades = upgrades.size()
	$UpgradeContainer/UpgradesMenu.add_child(counter_attack_instance)
	counter_attack = counter_attack_instance

	counter_attack_instance.connect("counterAttackAvailable", on_counter_attack_available)
	counter_attack_instance.connect("counterAttack", on_counter_attack_purchased)
	counter_attack_instance.connect("mouse_entered", show_counter_attack_hover_information)
	counter_attack_instance.connect("mouse_exited", hide_upgrade_hover_information)

func connect_signals():
	var initial_loop = true
	for structure in structures:
		# Connect structure to HUD
		structure.connect("structurePurchased", _on_structure_purchased.bind(structure))
		structure.connect("increaseCurrency", _on_generate_currency)
		structure.connect("mouse_entered", show_structure_hover_information.bind(structure))
		structure.connect("mouse_exited", hide_structure_hover_information)
		structure.connect("ownedNumberOfStructures", counter_attack._on_owned_number_of_structures)

		# Connect to upgrades
		for upgrade in upgrades:
			if initial_loop:
				# Connect upgrade to HUD
				upgrade.connect("upgradePurchased", _on_upgrade_purchased.bind(upgrade))
				upgrade.connect("mouse_entered", show_upgrade_hover_information.bind(upgrade))
				upgrade.connect("mouse_exited", hide_upgrade_hover_information)
				upgrade.connect("upgradeUnlocked", on_new_upgrade_unlocked)
				upgrade.connect("upgradePurchased", counter_attack._on_upgrade_purchased)

			if structure.structure_id == upgrade.structure_id:
				structure.connect("ownedNumberOfStructures", upgrade._on_owned_number_of_structures)
				upgrade.connect("applyMultiplier", structure._on_apply_upgrade_multiplier)
			
			if structure.structure_id == upgrade.additional_structure_id:
				upgrade.connect("additiveMultiplier", structure._on_additive_upgrade_multiplier)
			
			if structure.structure_id in upgrade.additonal_multipliers.keys():
				structure.connect("ownedNumberOfStructures", upgrade._on_owned_number_of_structures)

			# Connect upgrades of the same type
			# Upgrades of the same type with a lower level report to the higher-level upgrades of the same type
			# in order to unlock them when they are purchased
			for otherUpgrade in upgrades:
				if upgrade.upgrade_type_id == otherUpgrade.upgrade_type_id and otherUpgrade.upgrade_level < upgrade.upgrade_level:
					if not otherUpgrade.is_connected("upgradePurchased", upgrade._on_upgrade_type_level_inreased):
						otherUpgrade.connect("upgradePurchased", upgrade._on_upgrade_type_level_inreased.bind(otherUpgrade.upgrade_level))

			
		initial_loop = false

func _on_generate_currency(value: int):
	set_points(points + value)
	updatePoints.emit(points) 
	increaseTotalPoints.emit(value)   

func _on_structure_purchased(cost: int, structure: TextureButton):
	set_points(points - cost)
	updatePoints.emit(points)
	structurePurchased.emit(structure)

func _on_upgrade_purchased(cost: int, upgrade: TextureButton):
	set_points(points - cost)
	updatePoints.emit(points)
	upgradePurchased.emit(upgrade)

func set_points(new_points: int):
	points = new_points
	for structure in structures:
		if points < structure.current_cost.get_value():
			structure.disable_button()
		else:
			structure.enable_button()
	
	for upgrade in upgrades:
		if points < upgrade.cost.get_value():
			upgrade.disable_button()
		else:
			upgrade.enable_button()
	
	if points < counter_attack.cost.get_value():
		counter_attack.disable_button()
	else:
		counter_attack.enable_button()

func show_structures_menu():
	$StructuresMenuSprite.visible = true
	$StructureContainer/StructureMenu.visible = true
	$StructureContainer.mouse_filter = Control.MOUSE_FILTER_PASS

	$UpgradesMenuSprite.visible = false
	$UpgradeContainer/UpgradesMenu.visible = false
	$UpgradeContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_upgrades_menu():
	$StructuresMenuSprite.visible = false
	$StructureContainer/StructureMenu.visible = false
	$StructureContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	$UpgradesMenuSprite.visible = true
	$UpgradeContainer/UpgradesMenu.visible = true
	$UpgradeContainer.mouse_filter = Control.MOUSE_FILTER_PASS

	$UpgradeButton/NewUpgradeAvailable.visible = false

func show_structure_hover_information(structure: TextureButton):
	$StructureHoverInformation.set_structure_information(structure)
	$StructureHoverInformation.visible = true

func hide_structure_hover_information():
	$StructureHoverInformation.visible = false

func show_upgrade_hover_information(upgrade: TextureButton):
	var structure_name = "Clicking"

	for structure in structures:
		if structure.structure_id == upgrade.structure_id:
			structure_name = structure.structure_name

	$UpgradeHoverInformation.set_upgrade_information(upgrade, structure_name)
	$UpgradeHoverInformation.visible = true

func show_counter_attack_hover_information():
	$UpgradeHoverInformation._on_counter_attack_hover(counter_attack)
	$UpgradeHoverInformation.visible = true

func hide_upgrade_hover_information():
	$UpgradeHoverInformation.visible = false

func update_structure_unlock_status(total_points: int):
	for structure in structures:
		if not structure.has_been_unlocked:
			structure.on_total_points_increased(total_points)

func on_new_upgrade_unlocked():
	$UpgradeButton/NewUpgradeAvailable.visible = true

func on_counter_attack_available():
	counterAttackAvailable.emit()

func on_counter_attack_purchased():
	counterAttackPurchased.emit()
