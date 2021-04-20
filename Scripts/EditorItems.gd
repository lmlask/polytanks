extends Button

var id = 0

func _ready():
	pass # Replace with function body.

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				print("LMB")
				pass
			BUTTON_RIGHT:
				owner.menu.show_menu(self)
				owner.menu.rect_position = get_global_mouse_position()
				print(event.position)
				
func add(item,id):
	var but = self.duplicate()
	but.id = id
	but.text = item +"-"+ str(id)
	get_parent().add_child(but)
	but.owner = owner
	but.show()
