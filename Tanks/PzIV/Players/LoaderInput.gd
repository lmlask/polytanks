extends Node

func _process(delta):
	if not GameState.role == GameState.Role.Loader:
		return
	manageCamera()

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
