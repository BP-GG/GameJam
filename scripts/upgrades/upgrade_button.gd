extends TextureButton

signal upgradePurchased(cost)
signal applyMultiplier(points)
signal additiveMultiplier(points)
signal upgradeUnlocked

var upgrade_type_id: int = 0
var structure_id: int = 0
var additional_structure_id: int = 0

var structures_required: int = 0
var upgrade_level: int = 0
var current_upgrade_type_level: int = 0

var cost: NumberValue = NumberValue.new()
var production_rate_multiplier: float = 0
var additonal_multipliers: Dictionary = {}
var current_additional_multipliers: Dictionary = {}

var upgrade_name: String
var description: String
var upgrade_sprite: Texture

var hasBeenPurchased = false

var unlock_conditions: Dictionary = {
	"all_required_structures_owned": false,
	"all_lower_level_upgrade_owned": false,
}

func set_values(values: Dictionary, number_of_structures: int):
	upgrade_type_id = values.upgrade_type_id
	structure_id = values.structure_id
	additional_structure_id = values.additional_structure_id
	structures_required = values.structures_required
	upgrade_level = values.level
	cost.set_value(values.cost)
	production_rate_multiplier = values.multiplier
	additonal_multipliers = values.extra_multipliers_per_structure_owned
	upgrade_name = values.name
	description = values.description
	upgrade_sprite = load(values.sprite_url)

	intiailize_additional_multipliers(number_of_structures)

	update_display()
	disable_button()

	_on_owned_number_of_structures(0, -1)
	_on_upgrade_type_level_inreased(0, 0)
	check_upgrade_status()

func intiailize_additional_multipliers(number_of_structures: int):
	for i in range(number_of_structures):
		current_additional_multipliers[i] = 0

func update_display():
	$Sprite2D.texture = upgrade_sprite
	$Name.text = upgrade_name
	$Cost/ValueLabel.text = cost.show()

func _on_pressed():
	upgradePurchased.emit(cost.get_value())
	hasBeenPurchased = true
	applyMultiplier.emit(production_rate_multiplier)
	additiveMultiplier.emit(get_additive_multiplier())
	check_upgrade_status()

func disable_button():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$DisabledOverlay.visible = true

func enable_button():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$DisabledOverlay.visible = false

func _on_owned_number_of_structures(owned_num: int, owned_structure_id: int):
	if owned_num >= structures_required:
		unlock_conditions.all_required_structures_owned = true

	if owned_structure_id in additonal_multipliers.keys():
		current_additional_multipliers[owned_structure_id] = additonal_multipliers[owned_structure_id] * owned_num

		if hasBeenPurchased:
			additiveMultiplier.emit(get_additive_multiplier())

	check_upgrade_status()

func get_additive_multiplier():
	var new_multiplier = 0

	if upgrade_type_id < 7:
		for value in current_additional_multipliers.values():
			new_multiplier += value
	

	return new_multiplier
		
func _on_upgrade_type_level_inreased(_cost: int, new_level: int):
	current_upgrade_type_level = new_level

	if current_upgrade_type_level == upgrade_level - 1:
		unlock_conditions.all_lower_level_upgrade_owned = true
	
	check_upgrade_status()

func unlock_conditions_met():
	return unlock_conditions.values().all(func(condition): return condition == true)

func check_upgrade_status():
	if unlock_conditions_met() and not hasBeenPurchased:
		visible = true
		upgradeUnlocked.emit()
	else:
		visible = false