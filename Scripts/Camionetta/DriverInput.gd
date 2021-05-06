extends Node

onready var engine = owner.owner.get_node("EngineController")
onready var tank = owner.owner

func _process(delta):
	if not GameState.role == GameState.Role.Driver:
		return
	manageCamera()
	manageIgnition()
	manageThrottleAndBrake(delta) #Do this another way
	manageTransmission()
	manageSteering()

func _physics_process(delta):
	if not GameState.role == GameState.Role.Driver:
		return
	manageSteeringPhysics()

func manageCamera():
	if Input.is_action_just_pressed("external_cam"):
		if get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current:
			owner.owner.get_node("CameraRig/Target/ClippedCamera").current = true #FIX node references
		else:
			get_parent().get_node("Camera").set_current()
			get_parent().get_node("Camera").resetCamera()
	if Input.is_action_just_pressed("action") and get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current and get_parent().get_node("Camera").aimedObject:
		get_parent().get_node("Camera").aimedObject.interact()


func manageThrottleAndBrake(delta):
	# Manage throttle
	if Input.is_action_pressed("ui_up"):
		engine.throttle = lerp(engine.throttle, 1.0, delta*2)
		engine.brake = lerp(engine.brake, 0.0, delta*2)
#		engine.throttle = clamp(engine.throttle, 0.0, 1.0)
		if engine.throttle > 0.99:
			engine.throttle = 1
		elif engine.throttle < 0.01:
			engine.throttle = 0
	elif Input.is_action_pressed("brake"):
		engine.brake = lerp(engine.brake, 1.0, delta*2)
		engine.throttle = lerp(engine.throttle, 0.0, delta*2)
		if engine.brake > 0.99:
			engine.brake = 1
		elif engine.brake < 0.01:
			engine.brake = 0
	else:
		engine.brake = lerp(engine.brake, 0.0, delta*2)
		engine.throttle = lerp(engine.throttle, 0.0, delta*2)
		
func manageIgnition():
	#Startup and shutdown
	if Input.is_action_just_pressed("ignition"):
		if engine.state == "OFF" or engine.state == "OFF WARM":
			engine.engineStartUp()
		elif engine.state == "ON":
			engine.engineShutdown()
			
func manageTransmission():
	if Input.is_action_pressed("clutch"):
		engine.clutch = 1
	else:
		engine.clutch = 0
		
	if engine.clutch:
		if Input.is_action_just_pressed("gear_up") and engine.gear < engine.forward_gears:
			engine.gear += 1
			print(engine.gear)
		elif Input.is_action_just_pressed("gear_down") and engine.gear > -engine.reverse_gears:
			engine.gear -= 1
		elif Input.is_action_just_pressed("gear_neutral"):
			engine.gear = 0

func manageSteering():
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		engine.turning = true
	else:
		engine.turning = false
		
func manageSteeringPhysics():
	if Input.is_action_pressed("ui_right"):
		tank.turning_dir = "right"
	elif Input.is_action_pressed("ui_left"):
		tank.turning_dir = "left"
	else:
		tank.turning_dir = null
