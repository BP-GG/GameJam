extends TextureButton

signal upgradePurchased(cost, level)
signal applyMultiplier(points)

var upgrade_type_id: int = 0
var structure_id: int = 0

var structures_required: int = 0
var upgrade_level: int = 0
var current_upgrade_type_level: int = 0

var cost: int = 0
var production_rate_multiplier: float = 0

var upgrade_name: String
var description: String
var upgrade_sprite: Texture

var unlock_conditions: Dictionary = {
	"all_required_structures_owned": false,
	"all_lower_level_upgrade_owned": false,
}

func set_values(values: Dictionary):
	upgrade_type_id = values.upgrade_type_id
	structure_id = values.structure_id
	structures_required = values.structures_required
	upgrade_level = values.level
	cost = values.cost
	production_rate_multiplier = values.multiplier
	upgrade_name = values.name
	description = values.description
	upgrade_sprite = load(values.sprite_url)

	update_display()
	disable_button()
	
	_on_owned_number_of_structures(0)
	_on_upgrade_type_level_inreased(0, 0)
	if unlock_conditions_met():
		visible = true
	else:
		visible = false

func update_display():
	$Sprite2D.texture = upgrade_sprite
	$Name.text = upgrade_name
	$Cost/ValueLabel.text = str(cost)

func _on_pressed():
	upgradePurchased.emit(cost, upgrade_level)
	applyMultiplier.emit(production_rate_multiplier, )

func disable_button():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$DisabledOverlay.visible = true

func enable_button():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$DisabledOverlay.visible = false

func _on_owned_number_of_structures(owned_num: int):
	if owned_num >= structures_required:
		unlock_conditions.all_required_structures_owned = true

func _on_upgrade_type_level_inreased(_cost: int, new_level: int):
	current_upgrade_type_level = new_level

	if current_upgrade_type_level == upgrade_level - 1:
		unlock_conditions.all_lower_level_upgrade_owned = true

func unlock_conditions_met():
	return unlock_conditions.values().all(func(condition): return condition == true)
