extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var engine = owner.owner.get_node("EngineController")
onready var transmission_sfx = owner.owner.get_node("Sfx/transmission_sfx")
onready var gear3_sfx = preload("res://Sfx/gear3.wav")
onready var gear2_sfx = preload("res://Sfx/gear2.wav")
onready var tank = owner.owner
onready var gearShift = owner.owner.get_node("Interior/HullInterior/Dynamic/GearShift")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if not GameState.role == GameState.Role.Driver:
		return

#func _input(event): #_input, these functions should be called under input
	manageCamera()
	manageIgnition()
	manageThrottleAndBrake(delta) #Do this another way
	manageTransmission()
	manageSteering()

func manageCamera():
	if Input.is_action_just_pressed("external_cam"):
		if get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current:
			owner.owner.get_node("CameraRig/Target/ClippedCamera").current = true #FIX node references
		else:
			get_parent().get_node("Camera").set_current()
			get_parent().get_node("Camera").resetCamera()
	if Input.is_action_just_pressed("action") and get_parent().get_node("Camera/OuterGimbal/InnerGimbal/ClippedCamera").current and get_parent().get_node("Camera").aimedObject:
		get_parent().get_node("Camera").aimedObject.interact()
	
func _physics_process(delta):
	if not GameState.role == GameState.Role.Driver:
		return
	manageSteeringPhysics() #To be fixed

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
		
	if Input.is_action_just_pressed("clutch"):
		transmission_sfx.stream = gear3_sfx
		transmission_sfx.play()
	if engine.clutch:
		if Input.is_action_just_pressed("gear_up") and engine.gear < engine.forward_gears:
			engine.gear += 1
			transmission_sfx.stream = gear2_sfx
			transmission_sfx.play()
			gearShift.shift(engine.gear)
		elif Input.is_action_just_pressed("gear_down") and engine.gear > -engine.reverse_gears:
			engine.gear -= 1
			transmission_sfx.stream = gear2_sfx
			transmission_sfx.play()
			gearShift.shift(engine.gear)
		elif Input.is_action_just_pressed("gear_neutral"):
			engine.gear = 0
			transmission_sfx.stream = gear2_sfx
			transmission_sfx.play()
			gearShift.shift(engine.gear)

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
