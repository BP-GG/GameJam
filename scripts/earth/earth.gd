extends Node2D

var sprite = preload("res://scenes/animations/earth_riot.tscn")
var riots: Array[Sprite2D] = []

var time: float = 0.0
var speed: float = 0.3
var animation_offset = 0
var offset = 0.7

func add_riot():
	var node: Sprite2D = sprite.instantiate()
	node.distance_from_center = 100 + floor(riots.size() / 30.0) * 25

	riots.append(node)
	$CircularPath.add_child(node)

	if (riots.size() == 1):
		$CircularPath/RiotTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	for i in range(riots.size()):
		var angle = speed * time + speed * offset * i
		var nodeRotation = Vector2(cos(angle), sin(angle))
		riots[i].position = nodeRotation * riots[i].distance_from_center
		riots[i].rotation = angle + PI/2

func _on_riot_timer_timeout():
	for i in range (riots.size()):
		var tween = create_tween()
		var node_distance = riots[i].distance_from_center

		tween.tween_property(riots[i], "distance_from_center", node_distance + 10, 0.5).set_delay(i % 31)
		tween.chain().tween_property(riots[i], "distance_from_center", node_distance, 0.5)