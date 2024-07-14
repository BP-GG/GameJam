extends TextureButton

signal structurePurchased(cost)
signal increaseCurrency(points)
signal ownedNumberOfStructures(number_of_structures)

var structure_id: int = 0
var max_upgrades: int = 0

var base_cost: int = 0
var base_rate: float = 0

var structure_name: String
var structure_description: String
var structure_sprite: Texture

var current_cost: NumberValue = NumberValue.new()
var multipliers: int = 1
var quantity: int = 0

var total_points_generated: NumberValue = NumberValue.new()

const structure_timer = preload("res://scenes/upgrades/structure_timer.tscn")

var has_been_unlocked = false

func set_values(values: Dictionary):
	structure_id = values.id
	max_upgrades = values.max_upgrades
	
	base_cost = values.base_cost
	current_cost.set_value(base_cost)
	base_rate = values.base_rate
	structure_name = values.name
	structure_description = values.description
	structure_sprite = load(values.sprite_url)

	$Sprite2D.texture = structure_sprite
	$Name.text = structure_name

	update_display()
	disable_button()

	visible = false

func update_display():
	$Cost/ValueLabel.text = current_cost.show()
	$Quantity.text = str(quantity)

func generate_new_structure_instance():
	var new_structure = structure_timer.instantiate()
	new_structure.set_base_rate(base_rate)
	new_structure.connect("produceCurrency", _on_structure_currency_produced)
	add_child(new_structure)

func _on_pressed():
	quantity += 1
	structurePurchased.emit(current_cost.get_value())
	ownedNumberOfStructures.emit(quantity)

	if (quantity == 1):
		current_cost.set_value(ceil(base_cost * 1.15))
	else:
		var new_cost = base_cost * pow(1.15, quantity)
		current_cost.set_value(ceil(new_cost))
		
	update_display()
	generate_new_structure_instance()

func _on_structure_currency_produced(value: float):
	increaseCurrency.emit(value * multipliers)
	total_points_generated.increase_value(value * multipliers)

func _on_apply_upgrade_multiplier(multiplier: int):
	multipliers *= multiplier

func disable_button():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$DisabledOverlay.visible = true

func enable_button():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$DisabledOverlay.visible = false

func on_total_points_increased(total_points: int):
	if total_points >= base_cost:
		has_been_unlocked = true
		visible = true