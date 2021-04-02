extends RigidBody

# control variables
export var engineSpeedScaleFac : float = 60.0
# currently, raycast driver expects this array to exist in the controller script
var rayElements : Array = []
var drivePerRay : float = 100.0
export var active = false

var driveForce = 0
var dir

#references
onready var role = $RoleController.role
onready var engine = $EngineController
onready var brakeForce = engine.brakeForce


#stats
var speed = 0

func _process(delta):
	role = $RoleController.role

	

func handleTankDrive(delta) -> void:

	for ray in rayElements:
		if engine.clutch == 0:
			if engine.gear > 0:
				dir = 1
			elif engine.gear == 0:
				dir = 1
			elif engine.gear == -1:
				dir = -1
		
		drivePerRay = engine.enginePower / rayElements.size()
		
		if role == "driver":
			if speed > 1 and engine.gear != 0:
				if Input.is_action_pressed("ui_left"):
					add_torque(Vector3(0, (50*log(speed))/engine.gear, 0))
		
				if Input.is_action_pressed("ui_right"):
					add_torque(Vector3(0, (-50*log(speed))/engine.gear, 0))
					
			elif speed < -1 and engine.gear != 0:
				if Input.is_action_pressed("ui_left"):
					add_torque(Vector3(0, (30*log(-speed))/engine.gear, 0))
		
				if Input.is_action_pressed("ui_right"):
					add_torque(Vector3(0, (-30*log(-speed))/engine.gear, 0))
				
		driveForce = dir * drivePerRay * global_transform.basis.z
		ray.applyDriveForce(driveForce)
			

func _ready() -> void:
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

func calcStats(delta):
	speed = 3.6 * self.transform.basis.xform_inv(self.linear_velocity).z
	

	
	
