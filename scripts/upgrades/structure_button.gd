extends TextureButton

signal structurePurchased(cost)
signal increaseCurrency(points)

@export var base_cost: int = 0
@export var base_rate: float = 0
@export var structure_name: String
@export var structure_sprite: Texture

var current_cost: int = 0
var quantity: int = 0

const structure_timer = preload("res://scenes/upgrades/structure_timer.tscn")

func _ready():
	current_cost = base_cost
	$Sprite2D.texture = structure_sprite
	$Name.text = structure_name
	update_display()
	disable_button()

func update_display():
	$Cost/ValueLabel.text = str(current_cost)
	$Quantity.text = str(quantity)

func generate_new_structure_instance():
	var new_structure = structure_timer.instantiate()
	new_structure.set_base_rate(base_rate)
	new_structure.connect("produceCurrency", _on_structure_curency_produced)
	add_child(new_structure)

func _on_pressed():
	quantity += 1
	structurePurchased.emit(current_cost)

	if (quantity == 1):
		current_cost = ceil(base_cost * 1.15)
	else:
		var new_cost = base_cost * pow(1.15, quantity)
		current_cost = ceil(new_cost)
		
	update_display()
	generate_new_structure_instance()

func _on_structure_curency_produced(value: float):
	increaseCurrency.emit(value)

func disable_button():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$DisabledOverlay.visible = true

func enable_button():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$DisabledOverlay.visible = false