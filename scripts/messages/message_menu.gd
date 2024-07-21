extends CanvasLayer

const item_spacing = 10
const item_height = 94

var message_data: Array = []
var displayed_messages: Array[Node] = []
var full_container_height = 0

var message_scene = preload("res://scenes/messages/message.tscn")

var scroll_to_end: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load the messages
	var message_db = TextDatabase.new()
	message_db.load_from_path("res://data/messages.cfg")
	message_data = message_db.get_dictionary().values()

	displayed_messages = $ScrollContainer/VBoxContainer.get_children()
	update_full_height()
	scroll_to_last_item()

func _process(_delta):
	if scroll_to_end:
		scroll_to_last_item()

func update_full_height():
	if displayed_messages.size() == 0:
		return
		
	var num_of_messages = displayed_messages.size()

	full_container_height = num_of_messages * item_height + (num_of_messages - 1) * item_spacing

func scroll_to_last_item():
	$ScrollContainer.scroll_vertical = full_container_height - $ScrollContainer.size.y

func display_new_message(message: Dictionary):
	if message.id in displayed_messages.map(func(msg): return msg.id):
		return

	var msg_instance = message_scene.instantiate()
	msg_instance.set_values(message.text, message.id)
	$ScrollContainer/VBoxContainer.add_child(msg_instance)


	var tween = create_tween()
	msg_instance.modulate.a = 0
	tween.tween_property(msg_instance, "modulate:a", 1, 0.6)

	displayed_messages.append(msg_instance)
	update_full_height()
	scroll_to_end = true
	tween.tween_callback(stop_scroll_to_end).set_delay(1)

func stop_scroll_to_end():
	scroll_to_end = false

func _on_upgrade_purchased(upgrade: TextureButton):
	for message in message_data:
		if message.threshold_type == "upgrade" and message.threshold_name == upgrade.upgrade_name:
			display_new_message(message)

func _on_structure_purchased(structure: TextureButton):
	for message in message_data:
		if message.threshold_type == "structure" and message.threshold_name == structure.structure_name and message.threshold_value <= structure.quantity:
			display_new_message(message)

func _on_total_points_threshold_reached(points: float):
	for message in message_data:
		if message.threshold_type == "points" and message.threshold_value <= points:
			display_new_message(message)

func _on_counter_attack_ready():
	display_new_message({
		"id": 1000,
		"text": "All preparations are complete. The world prepares to launch a counter attack!"
	})