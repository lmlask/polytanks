extends Node

export var state = "OFF" #should be an enum

export var maxEnginePower : float
export var minRPM : float
export var forward_gears : int
export var reverse_gears : int
export var turnModifier : float

export var startup_time : float
export var rev_time : float
export var warm_startup_time : float
export var shutdown_time : float

#Top speed for each gear.
export var gearTopSpeeds = {
	-1 : 8,
	0 : 0,
	1 : 10,
	2 : 20,
	3 : 30,
	4 : 40,
	5 : 50,
	6 : 60 }

export var gearTorqueMods = {
			-1 : 0.7,
			0 : 0.2,
			1 : 1,
			2 : 0.7,
			3 : 0.4,
			4 : 0.3,
			5 : 0.2, 
			6 : 0.14
		}

export var gearSlideMods = {
			-1 : 1,
			0 : 0.1,
			1 : 1,
			2 : 0.8,
			3 : 0.6,
			4 : 0.4,
			5 : 0.3, 
			6 : 0.2
		}

var enginePower = maxEnginePower
var RPM = 0.25
var maxRPM = 1.0
var gear = 0
var clutch = 0
var throttle = 0
var brake = 0
var turning = false

# Called when the node enters the scene tree for the first time.
		
func _process(delta):
	manageRPM(delta)
	manageEnginePower(delta)
	
func engineStartUp():
	if state == "OFF":
		state = "STARTING"
		yield(get_tree().create_timer(startup_time), "timeout")
		state = "REVVING"
		yield(get_tree().create_timer(rev_time), "timeout")
		state = "ON"

		
	elif state == "OFF WARM":
		state = "STARTING"
		yield(get_tree().create_timer(warm_startup_time), "timeout")
		state = "REVVING"
		yield(get_tree().create_timer(rev_time), "timeout")
		state = "ON"

func engineShutdown():
	state = "SHUTTING DOWN"
	yield(get_tree().create_timer(shutdown_time), "timeout")
	state = "OFF WARM"

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
			elif turning:
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

func manageEnginePower(_delta):
	if state == "OFF" or state == "SHUTTING DOWN":
		enginePower = 0
	elif state == "ON":
		if clutch == 1 or gear == 0:
			enginePower = 0
		elif turning:
			enginePower = maxEnginePower * turnModifier * throttle
		else:
			enginePower = maxEnginePower * throttle
