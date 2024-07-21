extends Timer

signal produceCurrency(value)

var base_rate: float = 0

func set_base_rate(new_rate: float):
	base_rate = new_rate
	wait_time = 1 / base_rate
	start()

func _on_timeout():
	produceCurrency.emit(base_rate * wait_time)
