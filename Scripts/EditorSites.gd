extends Button

func _ready():
	pass # Replace with function body.


func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
#				owner.selected = 
				pass
			BUTTON_RIGHT:
				owner.menu.show_menu(self)
				owner.menu.rect_position = get_global_mouse_position()
				print(event.position)

func add(site):
	var but = self.duplicate()
	but.name = site
	but.text = site
	get_parent().add_child(but)
	but.owner = owner
	but.show()
