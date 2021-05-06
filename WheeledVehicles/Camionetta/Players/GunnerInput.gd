extends Node

onready var tank = owner.owner
onready var turretCon = owner.owner.get_node("TurretController")
var shell_number = 0

func _process(delta):
	if not GameState.role == GameState.Role.Gunner:
		return
	manageCamera()

	#Turning
	if Input.is_action_pressed("ui_left"):
		turretCon.dir = 1
	elif Input.is_action_pressed("ui_right"):
		turretCon.dir = -1
	else:
		turretCon.dir = 0
		
	#Elevation
	if Input.is_action_pressed("ui_up"):
		turretCon.eledir = -1
	elif Input.is_action_pressed("ui_down"):
		turretCon.eledir = 1
	else:
		turretCon.eledir = 0
		
		
	#Precision
	if Input.is_action_pressed("turret_fine"):
		turretCon.dir = turretCon.dir/3
		turretCon.eledir = turretCon.eledir/6

	if Input.is_action_pressed("ui_select"):
		if owner.owner.get_node("TurretController").loaded and owner.owner.get_node("TurretController").can_fire:
			turretCon.fire(get_tree().get_network_unique_id(),shell_number,true)
			owner.owner.VehicleMan.rpc("fire", str(GameState.tank), shell_number)
			shell_number += 1

func manageCamera():
	if Input.is_action_just_pressed("external_cam"):
		if get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current:
			owner.owner.get_node("CameraRig/Target/ClippedCamera").current = true #FIX node references
		else:
			get_parent().get_node("Camera").set_current()
			get_parent().get_node("Camera").resetCamera()
	if Input.is_action_just_pressed("action") and get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current and get_parent().get_node("Camera").aimedObject:
		get_parent().get_node("Camera").aimedObject.interact()
