extends Area

onready var driver_camera = get_parent().get_parent().get_parent().get_node("Players/Driver/Camera")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	driver_camera.togglePortMode(self, 0.3, 74, -0, -30, 30)
