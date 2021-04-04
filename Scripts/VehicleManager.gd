extends Node

export(NodePath) var vehiclePath
onready var vehicle_scene = load("res://Tanks/PzIV/PanzerIV.tscn") #Should be dynamic
onready var NM = get_node("../NetworkManager")
onready var vehicle : RigidBody = vehicle_scene.instance()
#onready var other_vehicle : RigidBody = vehicle_scene.instance()
var vehicleStartTransform : Transform
var tanks = []
var timer:float = 0.0
var players = {}

var start = [Vector3(-2,0.1,-12), Vector3(-12,0.1,-12),Vector3(6,0.1,-16),Vector3(14,0.1,-16)] #simple solution

func _ready():
	randomize()
	
#	get_parent().call_deferred("add_child", vehicle)
#	vehicle = get_node(vehiclePath)	
	

func _process(_delta):
	timer += _delta
	if timer > 0.01 and get_tree().has_network_peer(): #not a good solution
		rpc("set_pos", vehicle.transform)
#		add_random_tank()
		timer -= 0.01
	if Input.is_action_pressed("reset_vehicle"):
		vehicle.linear_velocity = Vector3()
		vehicle.angular_velocity = Vector3()
		vehicle.global_transform = vehicleStartTransform

func start():
#	get_parent().call_deferred("add_child", vehicle)
	for i in tanks:
		i.queue_free() #delete intro tanks
	GameState.setup_debug() #fix this, make it optional
	get_parent().add_child(vehicle)
#	get_parent().add_child(other_vehicle)
#	if GameState.mode == GameState.Mode.Client: #fix this, dont expand
	vehicle.translation = start[NM.players.keys().find(get_tree().get_network_unique_id())]
	players[get_tree().get_network_unique_id()] = vehicle
	vehicle.name = str(get_tree().get_network_unique_id())
#		vehicle.translation = start[1]
#		other_vehicle.translation = start[0]
#	else:
#		vehicle.translation = start[0] 
#		other_vehicle.translation = start[1]
	vehicle.rotate_y(-PI/2)
#	other_vehicle.rotate_y(-PI/2)
	vehicle.auto = false #set manual control
#	other_vehicle.auto = false #set manual control
	vehicle.VehicleMan = self
	vehicleStartTransform = vehicle.global_transform
	$"../CameraRig"._camTarget = vehicle #give cam target
	
	$"../DebugUI".enable()
#	rpc("start_remote_tank")
	#add additional vehicles for testing
	rpc("get_remote_tanks")
	rpc("add_tank", vehicle.translation)
	return
#
#remote func new_tank(t):
	

remote func get_remote_tanks():
	var nid = get_tree().get_rpc_sender_id()
	rpc_id(nid, "add_tank", vehicle.translation)

remote func add_tank(t):
	print("starting remote tank")
	var tank = vehicle_scene.instance()
	get_parent().add_child(tank)
	tank.name = str(get_tree().get_rpc_sender_id())
	tank.auto = false
	tank.translation = t#start[NM.players.keys().find(get_tree().get_network_unique_id())] #not correct

func load_intro_tanks():
	for i in range(11):
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.rotate_y(-PI/2)
		tank.VehicleMan = self
		tanks.append(tank)
	
	tanks[0].translation = Vector3(-10,0.1,-12)
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
	var sid = str(get_tree().get_rpc_sender_id())
	if get_parent().has_node(sid):
		get_parent().get_node(sid).transform = t
#	other_vehicle.transform = t
	


