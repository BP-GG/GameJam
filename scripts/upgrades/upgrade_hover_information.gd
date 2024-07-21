extends Node2D

var upgrade_button: TextureButton
var structure_name: String
var isCounterAttack: bool

func set_upgrade_information(btn: TextureButton, str_name: String):
	upgrade_button = btn
	structure_name = str_name
	update_display()
	visible = false

func update_display():
	if not isCounterAttack:
		$Level.text = "Level " + str(upgrade_button.upgrade_level) + " upgrade"
		$Name.text = upgrade_button.upgrade_name
		$Cost.text = upgrade_button.cost.show() + " RP"
		$Description.text = upgrade_button.description
		$Structure.text = "Makes " + structure_name + "s " + str(upgrade_button.production_rate_multiplier) + " times more effective"
		$Sprite2D.texture = upgrade_button.upgrade_sprite
		$Sprite2D.visible = true
	else:
		$Name.text = "Counter Attack"
		$Description.text = "It is time to launch a counter attack and fight back the oppressors."
		$Cost.text = upgrade_button.cost.show()
		$Sprite2D.visible = false

func _process(_delta):
	var pos_y = clamp(get_viewport().get_mouse_position().y, 180, 550)
	position.y = pos_y

func _on_counter_attack_hover(btn: TextureButton):
	upgrade_button = btn
	isCounterAttack = true
	update_display()
	visible = false
