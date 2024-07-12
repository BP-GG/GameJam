extends Node2D

var structure_button: TextureButton

func set_structure_information(btn: TextureButton):
	structure_button = btn
	update_display()
	visible = false

func update_display():
	var rate = structure_button.base_rate * structure_button.multipliers
	$Owned/Value.text = str(structure_button.quantity)
	$Name.text = structure_button.structure_name
	$Cost.text = str(structure_button.current_cost) + " RP"
	$Description.text = structure_button.structure_description
	$IndividualRate.text = "Each " + structure_button.structure_name + " produces " + str(rate) + " RP per second"
	$TotalRate.text = str(structure_button.quantity) + " producing " + str(rate * structure_button.quantity) + " RP per second"
	$TotalProduction.text = str(structure_button.total_points_generated) + " RP produced so far"
	$Sprite2D.texture = structure_button.structure_sprite

func _process(_delta):
	var pos_y = clamp(get_viewport().get_mouse_position().y, 180, 550)
	position.y = pos_y
