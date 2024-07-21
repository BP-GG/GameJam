extends TextureButton
signal counterAttack
signal counterAttackAvailable

var cost = NumberValue.new()

const structure_requirements = {
	0: 30,
	1: 25,
	2: 25,
	3: 25,
	4: 25
}

var required_number_of_upgrades = 0
var curr_number_of_upgrades = 0

var structure_unlock_conditions = {
	0: false,
	1: false,
	2: false,
	3: false,
	4: false
}

var unlock_conditions = {
	"all_required_structures_owned": structure_unlock_conditions,
	"all_required_upgrades_owned": false
}

var has_been_purchased = false

func _ready():
	check_upgrade_status()
	cost.set_value(1e9)

func _on_pressed():
	counterAttack.emit()

func disable_button():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	$DisabledOverlay.visible = true

func enable_button():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$DisabledOverlay.visible = false

func _on_owned_number_of_structures(owned_num: int, owned_structure_id: int):
	if owned_num >= structure_requirements[owned_structure_id]:
		structure_unlock_conditions[owned_structure_id] = true
		check_upgrade_status()

func _on_upgrade_purchased(_cost: int):
	curr_number_of_upgrades += 1

	if curr_number_of_upgrades == required_number_of_upgrades:
		unlock_conditions.all_required_upgrades_owned = true
		check_upgrade_status()

func unlock_conditions_met():
	return unlock_conditions.all_required_structures_owned.values().all(func(condition): return condition == true) and unlock_conditions.all_required_upgrades_owned

func check_upgrade_status():
	if unlock_conditions_met() and not has_been_purchased:
		has_been_purchased = texture_disabled
		visible = true
		counterAttackAvailable.emit()
	else:
		visible = false