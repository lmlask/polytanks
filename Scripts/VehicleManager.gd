extends Node

export(NodePath) var vehiclePath
onready var vehicle_scene = load("res://Tanks/PzIV/PanzerIV.tscn") #Should be dynamic

onready var vehicle : RigidBody = vehicle_scene.instance()
onready var other_vehicle : RigidBody = vehicle_scene.instance()
var vehicleStartTransform : Transform
var tanks = []
var timer:float = 0.0

var std_start = Vector3(-2,0.1,-12)
var alt_start = Vector3(-12,0.1,-12) #simple solution

func _ready():
	randomize()
	$"../DebugUI".vehicle = vehicle #define tank to use in debug
	
#	get_parent().call_deferred("add_child", vehicle)
#	vehicle = get_node(vehiclePath)	
	

func _process(_delta):
	timer += _delta
	if timer > 0.1:
		rpc("set_pos", vehicle.transform)
#		add_random_tank()
#		timer = 0.0
	if Input.is_action_pressed("reset_vehicle"):
		vehicle.linear_velocity = Vector3()
		vehicle.angular_velocity = Vector3()
		vehicle.global_transform = vehicleStartTransform

func start():
#	get_parent().call_deferred("add_child", vehicle)
	get_parent().add_child(vehicle)
	get_parent().add_child(other_vehicle)
	if GameState.mode == GameState.Mode.Client: #fix this, dont expand
		vehicle.translation = alt_start
		other_vehicle.translation = std_start
	else:
		vehicle.translation = std_start 
		other_vehicle.translation = alt_start
	vehicle.rotate_y(-PI/2)
	other_vehicle.rotate_y(-PI/2)
	vehicle.auto = false #set manual control
	other_vehicle.auto = false #set manual control
	vehicle.VehicleMan = self
	vehicleStartTransform = vehicle.global_transform
	$"../CameraRig"._camTarget = vehicle #give cam target
	
	$"../DebugUI".enable()

	#add additional vehicles for testing
	return
	for i in range(1):
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.rotate_y(-PI/2)
		tank.VehicleMan = self
		tanks.append(tank)
	
	tanks[0].translation = Vector3(-10,0.1,-12)
	return
	tanks[1].translation = Vector3(6,0.1,-12)
	tanks[2].translation = Vector3(14,0.1,-12)
	
	tanks[3].translation = Vector3(-10,0.1,-16)
	tanks[4].translation = Vector3(-2,0.1,-16)
	tanks[5].translation = Vector3(6,0.1,-16)
	tanks[6].translation = Vector3(14,0.1,-16)
	
	tanks[7].translation = Vector3(-10,0.1,-8)
	tanks[8].translation = Vector3(-2,0.1,-8)
	tanks[9].translation = Vector3(6,0.1,-8)
	tanks[10].translation = Vector3(14,0.1,-8)
	
func add_random_tank():
	if tanks.size() > 0 and tanks.size() < 20: #only add tanks when tanks exists, ie game has started
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.rotate_y(rand_range(-3,3))
		tank.VehicleMan = self
		tank.translation = Vector3(rand_range(-100,100),1,rand_range(-100,100))
		tanks.append(tank)

func delete_tank(t):
	t.queue_free()
	tanks.erase(t)

remote func set_pos(t): #totally wrong re-wrtie all this
#	print(pos)
	other_vehicle.transform = t
	


