extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.hide()
	for i in GameState.Role.keys():
		print(i)
		var b = $Button.duplicate()
		b.text = i
		b.show()
		$Panel/VBoxContainer.add_child(b)

func toggle():
	$Panel.visible = !$Panel.visible
	if $Panel.visible: #merge into a function
		GameState.show_mouse()
	else:
		GameState.hide_mouse()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
