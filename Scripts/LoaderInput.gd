extends Node

func _process(delta):
	if not GameState.role == GameState.Role.Loader:
		return
	manageCamera()
	manageShells()

func manageCamera():
	if Input.is_action_just_pressed("external_cam"):
		if get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current:
#			get_tree().get_root().get_node("gameRoot/CameraRig/ClippedCamera").current = true
			owner.owner.get_node("CameraRig/Target/ClippedCamera").current = true #FIX node references
		else:
			get_parent().get_node("Camera").set_current()
			get_parent().get_node("Camera").resetCamera()
	if Input.is_action_just_pressed("action") and get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current and get_parent().get_node("Camera").aimedObject:
		get_parent().get_node("Camera").aimedObject.interact()

func manageShells():
	if Input.is_action_just_pressed("prev_shell"):
		if get_parent().get_node("Camera").aimedObject.name.substr(0, 3) == "Bin":
			get_parent().get_node("Camera").aimedObject.prev_shell()
	elif Input.is_action_just_pressed("next_shell"):
		if get_parent().get_node("Camera").aimedObject.name.substr(0, 3) == "Bin":
			get_parent().get_node("Camera").aimedObject.next_shell()
