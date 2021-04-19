extends PanelContainer

onready var rename = $VBoxContainer/Rename
onready var sitename = $VBoxContainer/Name
var item = null

func _ready():
	pass # Replace with function body.


func show_menu(node):
	item = node
	show()

func _on_Rename_pressed():
	rename.hide()
	sitename.show()
	sitename.text = item.name

func _on_Delete_pressed():
	owner.sites.erase(item.name)
	item.queue_free()
	hide()

func _on_Name_text_entered(new_text):
	owner.renamesite(item.name, new_text)
	rename.show()
	sitename.hide()
	hide()
	item.text = new_text
