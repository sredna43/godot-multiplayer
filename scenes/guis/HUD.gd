extends CanvasLayer

onready var label: Label = $CenteredText/CenterContainer/Text
var wait_time = 3
var current_time = wait_time

signal timer_complete
signal leave_button_pressed

func start_timer():
	while current_time >= 0:
		yield(get_tree().create_timer(1), "timeout")
		_decrease_timer_text()
		current_time -= 1
	label.text = "Go!!!"
	emit_signal("timer_complete")
	yield(get_tree().create_timer(1), "timeout")
	label.hide()
	
func _decrease_timer_text():
	label.text = str(current_time)

func _on_LeaveButton_pressed() -> void:
	emit_signal("leave_button_pressed")

func display_win(text):
	label.show()
	label.text = text
