extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.hide()

func setup_panel():
	for n in $Panel/VBoxContainer.get_children():
		n.queue_free()
	for i in GameState.Role.size():
		var b = $Button.duplicate()
		var nid = get_tree().get_network_unique_id()
		b.text = GameState.Role.keys()[i]
		b.role = i
		if GameState.roles.has(i):
			b.text += " ID:"+str(GameState.roles[i])
		b.show()
		$Panel/VBoxContainer.add_child(b)
		b.owner = self

func toggle():
	$Panel.visible = !$Panel.visible
	if $Panel.visible: #merge into a function
		setup_panel()
		GameState.show_mouse()
	else:
		GameState.hide_mouse()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func button_pressed(i):
	GameState.change_roles(i)
	
