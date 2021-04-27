extends PanelContainer

onready var rename = $VBoxContainer/Rename
onready var sitename = $VBoxContainer/Name
var item = null

func _ready():
	pass # Replace with function body.


func show_menu(node):
	item = node
	if item.is_in_group("item"):
		rename.hide()
	else:
		rename.show()
	show()

func _on_Rename_pressed():
	rename.hide()
	sitename.show()
	sitename.text = item.text.split("-")[0]

func _on_Delete_pressed():
	if item.is_in_group("site"):
		var _err = R.Map.sites.erase(item.id)
	elif item.is_in_group("item"):
		var _err = R.Map.items.erase(item.id)
		print(R.Map.items)
	elif item.is_in_group("loc"):
		var _err = R.Map.locations.erase(item.id)
	item.queue_free()
	hide()

func _on_Name_text_entered(new_text):
	if item.is_in_group("site"):
		R.Map.sites[item.id] = new_text
	elif item.is_in_group("loc"):
		R.Map.locations[item.id].remove(2)
		R.Map.locations[item.id].insert(2,new_text)
	rename.show()
	sitename.hide()
	hide()
	item.text = new_text+"-"+str(item.id)


func _on_Cancel_pressed():
	rename.show()
	sitename.hide()
	hide()


func _on_Name_text_changed(_new_text):
	get_tree().set_input_as_handled()
