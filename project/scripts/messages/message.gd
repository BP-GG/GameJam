extends Control

var text: String = ""
var id: int = -1

func set_values(msg_text: String, msg_id: int):
	text = msg_text
	id = msg_id
	update_display()

func show_contents():
	$ColorRect.visible = true
	$Label.visible = true

func hide_contents():
	$ColorRect.visible = false
	$Label.visible = false

func update_display():
	$Label.text = text