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
	sitename.text = item.text

func _on_Delete_pressed():
	R.Map.sites.erase(item.id)
	item.queue_free()
	hide()

func _on_Name_text_entered(new_text):
	R.Map.sites[item.id] = new_text
	rename.show()
	sitename.hide()
	hide()
	item.text = new_text
