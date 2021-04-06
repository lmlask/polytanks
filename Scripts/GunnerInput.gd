extends Node

#onready var turretCon = get_parent().get_parent().get_parent().get_node("TurretController")
onready var turretCon = owner.owner.get_node("TurretController")

func _ready():
	pass

func _process(delta):
	if not GameState.role == GameState.Role.Gunner:
		return
	#Traverse mode
	if Input.is_action_just_pressed("traverse_manual"):
		if turretCon.traverse_mode == "power":
			turretCon.toggleTraverseMode()
	elif Input.is_action_just_pressed("traverse_power"):
		if turretCon.traverse_mode == "manual":
			turretCon.toggleTraverseMode()
	
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
