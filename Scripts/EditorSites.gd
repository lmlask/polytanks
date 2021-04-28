extends Button

var id = 0

func _ready():
	pass # Replace with function body.

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				owner.SiteLabel.text = "Site: " + text
				R.Map.site_selected = id
				owner.reload_items(id)
			BUTTON_RIGHT:
				owner.menu.show_menu(self)
				owner.menu.rect_position = get_global_mouse_position()
				print(event.position)

func add(site,newid):
	var but = self.duplicate()
	but.id = newid
	but.text = site+"-"+str(newid)
	get_parent().add_child(but)
	but.owner = owner
	but.show()
