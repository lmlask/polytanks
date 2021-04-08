extends Button

var role

func _on_Button_pressed():
	owner.button_pressed(role)
