extends CanvasLayer

onready var timer_label: Label = $MarginContainer/CenterContainer/CountdownTimer
var wait_time = 3
var current_time = wait_time

signal timer_complete

func start_timer():
	while current_time >= 0:
		yield(get_tree().create_timer(1), "timeout")
		_decrease_timer_text()
		current_time -= 1
	timer_label.text = "Go!!!"
	emit_signal("timer_complete")
	yield(get_tree().create_timer(1), "timeout")
	timer_label.hide()
	
func _decrease_timer_text():
	timer_label.text = str(current_time)
