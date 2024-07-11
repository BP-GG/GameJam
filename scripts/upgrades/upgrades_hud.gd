extends CanvasLayer

signal newRiotCreated
signal updatePoints(points)

var points = 0

var structure_btn = preload("res://scenes/upgrades/structure_button.tscn")
var upgrade_btn = preload("res://scenes/upgrades/upgrade_button.tscn")

var structures: Array[TextureButton] = []
var upgrades = []

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

		# Adjust position and add vertical padding (pad = 34)
		structure_instance.position.x = -300
		structure_instance.position.y = -402 + i * (structure_instance.size.y + 34) 

		# Connect the signals
		connect_structure_signals(structure_instance)

	var upgrade_db = TextDatabase.new()
	upgrade_db.load_from_path("res://data/upgrades.cfg")
	var upgrade_data = upgrade_db.get_dictionary().values()

	# Add the data as buttons in the Upgrades Menu of the HUD
	for i in range(upgrade_data.size()):

		# Add child instance
		var upgrade_instance = upgrade_btn.instantiate()
		upgrade_instance.set_values(upgrade_data[i])
		$UpgradeContainer/UpgradesMenu.add_child(upgrade_instance)

		# Connect the signals
		connect_upgrade_signals(upgrade_instance)
	
	show_structures_menu()

func connect_structure_signals(structure: TextureButton):
	structure.connect("structurePurchased", _on_structure_purchased.bind(structure.structure_name.to_lower()))
	structure.connect("increaseCurrency", _on_generate_currency)

func connect_upgrade_signals(upgrade: TextureButton):
	pass

func _on_generate_currency(value: int):
	set_points(points + value)
	updatePoints.emit(points)    

func _on_structure_purchased(cost: int, structure: String):
	set_points(points - cost)
	updatePoints.emit(points)
	print("HERE")
	print(structure)
	if structure.to_lower() == "riot":
		newRiotCreated.emit()

func set_points(new_points: int):
	points = new_points
	for structure in $StructureContainer/StructureMenu.get_children():
		if points < structure.current_cost:
			structure.disable_button()
		else:
			structure.enable_button()

func show_structures_menu():
	$StructuresMenuSprite.visible = true
	$StructureContainer/StructureMenu.visible = true
	$UpgradesMenuSprite.visible = false
	$UpgradesMenu.visible = false

func show_upgrades_menu():
	$StructuresMenuSprite.visible = false
	$StructureContainer/StructureMenu.visible = false
	$UpgradesMenuSprite.visible = true
	$UpgradesMenu.visible = true