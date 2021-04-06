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
	if timer > 0.1 and get_tree().has_network_peer(): #not a good solution
		if GameState.role == GameState.Role.Driver:
			rpc("set_pos", vehicle.transform)
		if GameState.role == GameState.Role.Gunner:
			rpc("set_tur", vehicle.get_node("Visuals/turret").rotation,vehicle.get_node("Visuals/turret/gun").rotation, str(GameState.DriverID[GameState.tank]) )
#		add_random_tank()
		timer -= 0.1
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
#	vehicle.translation = start[NM.players.keys().find(get_tree().get_network_unique_id())]
	vehicle.translation = start[GameState.tank]
	players[get_tree().get_network_unique_id()] = vehicle
	if GameState.role == GameState.Role.Driver:
		vehicle.name = str(get_tree().get_network_unique_id()) #set tank name to id as this is driver
	else:
		vehicle.name = str(GameState.DriverID[GameState.tank]) #set tank name to id of driver
		
#		vehicle.translation = start[1]
#		other_vehicle.translation = start[0]
#	else:
#		vehicle.translation = start[0] 
#		other_vehicle.translation = start[1]
	vehicle.rotate_y(-PI/2)
	vehicle.VehicleMan = self #dont think this is a good idea
#	other_vehicle.rotate_y(-PI/2)
	vehicle.auto = false #set manual control
#	other_vehicle.auto = false #set manual control
	
	vehicleStartTransform = vehicle.global_transform
	$"../CameraRig"._camTarget = vehicle #give cam target
	
	$"../DebugUI".enable()
#	rpc("start_remote_tank")
	#add additional vehicles for testing
	rpc("get_remote_tanks") #get remote tanks
	if GameState.role == GameState.Role.Driver: #dont add tanks if this is not driver
		rpc("add_tank", vehicle.translation, GameState.tank) #only add tanks if this is this driver
	return
#
#remote func new_tank(t):
	

remote func get_remote_tanks():
#	print(GameState.role)
	if GameState.role == GameState.Role.Driver: #only for drivers
		var nid = get_tree().get_rpc_sender_id()
		rpc_id(nid, "add_tank", vehicle.translation, GameState.tank)

remote func add_tank(t,tid):
#	print("starting remote tank")
	print(tid, GameState.tank)
	if not tid == GameState.tank: #if adding tank is the current drivers tank do no add
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.name = str(get_tree().get_rpc_sender_id())
		tank.auto = false
		tank.mode = RigidBody.MODE_KINEMATIC
		tank.translation = t#start[NM.players.keys().find(get_tree().get_network_unique_id())] #not correct
		tank.get_node("Players").queue_free()

func load_intro_tanks():
	for i in range(11):
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.rotate_y(-PI/2)
		tank.VehicleMan = self
		tanks.append(tank)
	
	tanks[0].translation = Vector3(-10,0.5,-12)
	tanks[1].translation = Vector3(6,0.5,-12)
	tanks[2].translation = Vector3(14,0.5,-12)
	
	tanks[3].translation = Vector3(-10,0.5,-16)
	tanks[4].translation = Vector3(-2,0.5,-16)
	tanks[5].translation = Vector3(6,0.5,-16)
	tanks[6].translation = Vector3(14,0.5,-16)
	
	tanks[7].translation = Vector3(-10,0.5,-8)
	tanks[8].translation = Vector3(-2,0.5,-8)
	tanks[9].translation = Vector3(6,0.5,-8)
	tanks[10].translation = Vector3(14,0.5,-8)
	
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

remote func set_tur(tr,te,id): #set turrent rotation, change to work like tank transform
	if get_parent().has_node(id):
		get_parent().get_node(id).get_node("Visuals/turret").rotation = tr
		get_parent().get_node(id).get_node("Visuals/turret/gun").rotation = te

remote func set_pos(t): #needs a re-wrtie all this
	var sid = str(get_tree().get_rpc_sender_id())
	if get_parent().has_node(sid):
		get_parent().get_node(sid).next_transform(t)
#	other_vehicle.transform = t
	
remotesync func fire(id):
	get_parent().get_node(id).get_node("TurretController").fire()

