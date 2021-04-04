extends Node

onready var engine_sfx = get_parent().get_node("Sfx/engine_sfx")
onready var engine_sfx2 = get_parent().get_node("Sfx/engine_sfx2")
onready var transmission_sfx = get_parent().get_node("Sfx/transmission_sfx")
onready var role = get_parent().get_node("RoleController").role
onready var startup_sfx = preload("res://Sfx/startup2.wav")
onready var startupwarm_sfx = preload("res://Sfx/warm_startup.wav")
onready var idle1_sfx = preload("res://Sfx/idle1.wav")
onready var shutdown_sfx = preload("res://Sfx/shutdown.wav")
onready var gear1_sfx = preload("res://Sfx/gear1.wav")
onready var gear2_sfx = preload("res://Sfx/gear2.wav")
onready var gear3_sfx = preload("res://Sfx/gear3.wav")
onready var rev2 = preload("res://Sfx/rev2.wav")
var gear_sounds

var enginePower = 0
export var state = "OFF"

export var maxEnginePower : float
export var brakeForce : float
export var minRPM : float
export var forward_gears : int
export var reverse_gears : int
export var turnModifier : float

#Top speed for each gear.
export var gearTopSpeeds : Dictionary = {
	-1 : 8,
	0 : 0,
	1 : 5,
	2 : 8,
	3 : 14,
	4 : 20,
	5 : 30,
	6 : 42
}

#Gear strength modifiers for fine adjustment.
#export var gearModifiers : Dictionary = {
#	-1 : 1,
#	0 : 0.3,
#	1 : 1,
#	2 : 0.9,
#	3 : 0.8,
#	4 : 0.7,
#	5 : 0.6,
#	6 : 0.5
#}

var RPM = 0.25
var maxRPM = 1.0
var gear = 0
var clutch = 0
var throttle = 0
var brake = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if state == "ON":
		engine_sfx.stream == idle1_sfx
		engine_sfx.play()
		
func _process(delta):
	#Startup and shutdown
	if Input.is_action_just_pressed("ignition") and role == "driver":
		if state == "OFF" or state == "OFF WARM":
			engineStartUp()
		elif state == "ON":
			engineShutdown()
			
	#Update player role
	role = get_parent().get_node("RoleController").role
	
	#Engine behavior
	manageThrottle(delta)
	manageBrake(delta)
	manageTransmission()
	manageRPM(delta)
	manageEngineSound()
	manageEnginePower(delta)
	
func engineStartUp():
	if state == "OFF":
		state = "STARTING"
		engine_sfx.stream = startup_sfx
		engine_sfx.play()
		
		var t = Timer.new()
		t.set_wait_time(17)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		state = "REVVING"
		
		t = Timer.new()
		t.set_wait_time(2.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		state = "ON"
		t.queue_free()
		
		engine_sfx.stream = idle1_sfx
		engine_sfx.play()
		
	elif state == "OFF WARM":
		state = "STARTING"
		engine_sfx.stream = startupwarm_sfx
		engine_sfx.play()
		
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		state = "REVVING"
		
		t = Timer.new()
		t.set_wait_time(1.5)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		state = "ON"
		t.queue_free()
		
		engine_sfx.stream = idle1_sfx
		engine_sfx.play()
	
func engineShutdown():
	state = "SHUTTING DOWN"
	engine_sfx.stream = shutdown_sfx
	engine_sfx.play()
	
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	state = "OFF WARM"
	
	t.queue_free()

func manageThrottle(delta):
	# Manage throttle
	if role == "driver":
		if Input.is_action_pressed("ui_up"):
			throttle = lerp(throttle, 1.0, delta*2)
			if throttle > 0.99:
				throttle = 1
			elif throttle < 0.01:
				throttle = 0
		else:
			throttle = lerp(throttle, 0.0, delta*1.5)
	else:
			throttle = lerp(throttle, 0.0, delta*1.5)
			
func manageBrake(delta):
	if role == "driver":
		if Input.is_action_pressed("brake"):
			brake = lerp(brake, 1.0, delta*3)
			if brake > 0.99:
				brake = 1
			elif brake < 0.01:
				brake = 0
		else:
			brake = lerp(brake, 0.0, delta*2)
	else:
			brake = lerp(brake, 0.0, delta*2)
		
func manageTransmission():
	if role == "driver":
		if Input.is_action_pressed("clutch"):
			clutch = 1
		else:
			clutch = 0
			
		if Input.is_action_just_pressed("clutch"):
			transmission_sfx.stream = gear3_sfx
			transmission_sfx.play()
			
		if clutch:
			if Input.is_action_just_pressed("gear_up") and gear < forward_gears:
				gear += 1
				transmission_sfx.stream = gear2_sfx
				transmission_sfx.play()
			elif Input.is_action_just_pressed("gear_down") and gear > -reverse_gears:
				gear -= 1
				transmission_sfx.stream = gear2_sfx
				transmission_sfx.play()
			elif Input.is_action_just_pressed("gear_neutral"):
				gear = 0
				transmission_sfx.stream = gear2_sfx
				transmission_sfx.play()

func manageRPM(delta):
	#RPM from 0.0 to 1.0
	var targetRPM
	
	# Manage different states
	if state == "OFF" or state == "OFF WARM":
		RPM = 0
	elif state == "SHUTTING DOWN":
		RPM = lerp(RPM, 0, delta)
	elif state == "REVVING":
		RPM = lerp(RPM, 0.7, delta)
	
	# Running engine
	elif state == "ON":
		# Neutral gear and clutch down
		if gear == 0 or clutch:
			targetRPM = clamp((maxRPM * throttle), minRPM, maxRPM)
		
		#Other gears
		elif gear > 0:
			var gearMinSpeed = gearTopSpeeds[gear-1] * 0.7
			var possibleRPM = 0
			
			if get_parent().speed < gearMinSpeed:
				targetRPM = 0
				
			#Performance while turning
			elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
				possibleRPM = (abs(get_parent().speed) * turnModifier) / gearTopSpeeds[gear]
				targetRPM = clamp(possibleRPM, 0, 1)
			
			#Straight line
			else:
				possibleRPM = (abs(get_parent().speed)) / gearTopSpeeds[gear]
				targetRPM = clamp(possibleRPM, 0, 1)
				
		elif gear < 0:
			var backspeed = -1 * get_parent().speed
			var gearMinSpeed = gearTopSpeeds[gear+1] * 0.7
			if backspeed < gearMinSpeed:
				targetRPM = 0
			else:
				targetRPM = abs(backspeed) / gearTopSpeeds[gear]
		
		#Kill engine if RPM too low
		if RPM < 0.15:
			if gear < 2:
				targetRPM = minRPM
			else:
				engineShutdown()
				
				
		#LERP RPM
		RPM = lerp(RPM, targetRPM, delta*2)
		
#		if RPM > 0.99: 
#			RPM = 1

func manageEnginePower(delta):

	if state == "OFF" or state == "SHUTTING DOWN":
		enginePower = 0
	elif state == "ON":
		if clutch == 1 or gear == 0:
			enginePower = 0
		elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
			enginePower = maxEnginePower * turnModifier * throttle
		else:
			enginePower = maxEnginePower * throttle

func manageEngineSound():
	if state == "ON":
		engine_sfx.pitch_scale = 0.9 + RPM - minRPM
