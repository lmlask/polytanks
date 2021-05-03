extends Node


var enginePower = 0
export var state = "OFF" #should be an enum

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

		
	elif state == "OFF WARM":
		state = "STARTING"
		
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

	
func engineShutdown():
	state = "SHUTTING DOWN"

	
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	
	state = "OFF WARM"
	
	t.queue_free()

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
