extends RigidBody
class_name PanzerIV

onready var Turret = $Visuals/Turret
onready var Gun = $Visuals/Turret/gun
# control variables
export var engineSpeedScaleFac : float = 60.0
# currently, raycast driver expects this array to exist in the controller script
var rayElements : Array = []
var drivePerRay : float = 100.0
#export var active = false

var driveForce = 0
var dir
var turning_dir = null

#references
#onready var role = $RoleController.role #probably not needed
onready var engine = $EngineController

var rnd_power
var rnd_turn
var auto = true
var VehicleMan = null
var prev_xform:Transform
var next_xform:Transform
var weight_xform = 0.0
var external_only = true

#stats
var speed = 0

func _process(delta):
#	role = $RoleController.role
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

func handleTankDrive(_delta) -> void:
	for ray in rayElements:
		if engine.clutch == 0:
			if engine.gear >= 0:
				dir = 1 
			elif engine.gear == -1:
				dir = -1
		
		drivePerRay = engine.enginePower / rayElements.size()
	
		if auto: #drive around randomly
			driveForce = global_transform.basis.z * rnd_power
			ray.applyDriveForce(driveForce)
			add_torque(Vector3(0,rnd_turn,0))
		
		else:
			driveForce = dir * drivePerRay * global_transform.basis.z * GameState.speed
			ray.applyDriveForce(driveForce)
			
	if turning_dir and speed > 1 and engine.gear != 0:
		if turning_dir == "left":
			add_torque(Vector3(0, (800*log(speed))/engine.gear, 0))
		elif turning_dir == "right":
			add_torque(Vector3(0, (-800*log(speed))/engine.gear, 0))
			
	elif turning_dir and speed < -1 and engine.gear != 0:
		if turning_dir == "left":
			add_torque(Vector3(0, (600*log(-speed))/engine.gear, 0))
		elif turning_dir == "right":
			add_torque(Vector3(0, (-600*log(-speed))/engine.gear, 0))


func _ready() -> void:
	if external_only and GameState.InGame:
		$Interior.queue_free()
	randomize()
	rnd_power = rand_range(10,30)
	rnd_turn = rand_range(-50,50)
	dir = 0
	# setup array of drive elements and setup drive power
	for node in get_node("Rays/Left").get_children():
		if node is RayCast:
			rayElements.append(node)
	for node in get_node("Rays/Right").get_children():
		if node is RayCast:
			rayElements.append(node)
	drivePerRay = engine.enginePower / rayElements.size()
	
func _physics_process(delta) -> void:
	handleTankDrive(delta)
	calcStats(delta)

func calcStats(_delta):
	speed = 3.6 * self.transform.basis.xform_inv(self.linear_velocity).z
