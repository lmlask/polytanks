extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if not GameState.role == GameState.Role.Radioman:
		return

#func _input(event): #_input, these functions should be called under input
	manageCamera()

func manageCamera():
	if Input.is_action_just_pressed("external_cam"):
		if get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current:
			owner.owner.get_node("CameraRig/Target/ClippedCamera").current = true #FIX node references
		else:
			get_parent().get_node("Camera").set_current()
			get_parent().get_node("Camera").resetCamera()
	if Input.is_action_just_pressed("action") and get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current and get_parent().get_node("Camera").aimedObject:
		get_parent().get_node("Camera").aimedObject.interact()
