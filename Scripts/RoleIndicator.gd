extends Label


onready var roleController = get_parent().get_parent().get_node("RoleController")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if roleController.role == "driver":
		text = ">>>"
	elif roleController.role == "radioman":
		text = "\n>>>"
	elif roleController.role == "gunner":
		text = "\n\n>>>"
	elif roleController.role == "commander":
		text = "\n\n\n>>>"
