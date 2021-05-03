extends RigidBody

# control variables
export var enginePower : float = 280.0
export var steeringAngle : float = 20.0

onready var engine = $EngineController
# currently, raycast driver expects this array to exist in the controller script
var rayElements : Array = []
var drivePerRay : float = enginePower
var frontRightWheel : RayCast
var frontLeftWheel : RayCast

var speed

var rnd_power
var rnd_turn
var auto = true
var VehicleMan = null
var prev_xform:Transform
var next_xform:Transform
var weight_xform = 0.0
var external_only = true

func _process(delta):
	if auto:
		if (transform.basis.y.y < 0 and transform.origin.y < 2) or translation.distance_to(Vector3(0,0,0)) > 500:
			translation = Vector3(0,0,0)
			VehicleMan.reset_tank(self)
#	elif GameState.role == GameState.Role.Gunner and GameState.roles.has(GameState.Role.Driver):
	elif (not GameState.role == GameState.Role.Driver and not GameState.DriverID[GameState.tank] == get_tree().get_network_unique_id()) or external_only:
		weight_xform += delta * 1/0.1
		transform = prev_xform.interpolate_with(next_xform, weight_xform)

func next_transform(t:Transform):
#	transform = t
	weight_xform = 0.0
	next_xform = t
	prev_xform = transform
	
func handle4WheelDrive(delta) -> void:
	for ray in rayElements:
		var dir = 0
		if Input.is_action_pressed("ui_up"):
			dir += 1
		if Input.is_action_pressed("ui_down"):
			dir -= 1
		
		drivePerRay = engine.enginePower / rayElements.size()
		

		# steering, set wheels initially straight
		frontLeftWheel.rotation_degrees.y = 0.0
		frontRightWheel.rotation_degrees.y = 0.0
		# if input provided, steer
		if Input.is_action_pressed("ui_left"):
			frontLeftWheel.rotation_degrees.y = steeringAngle
			frontRightWheel.rotation_degrees.y = steeringAngle
		if Input.is_action_pressed("ui_right"):
			frontLeftWheel.rotation_degrees.y = -steeringAngle
			frontRightWheel.rotation_degrees.y = -steeringAngle
		
		ray.applyDriveForce(dir * global_transform.basis.z * drivePerRay)

func _ready() -> void:
	# setup front right and front left wheels
	frontLeftWheel = get_node("RaysWheels/FL_ray")
	frontRightWheel = get_node("RaysWheels/FR_ray")
	# setup array of drive elements and setup drive power
	for node in get_node("RaysWheels").get_children():
		rayElements.append(node)
	print("Found ", rayElements.size(), " raycasts connected to wheeled vehicle, setting to provide ", drivePerRay, " power each.") 
	
func _physics_process(delta) -> void:
	handle4WheelDrive(delta)
	speed = 3.6 * self.transform.basis.xform_inv(self.linear_velocity).z
	
