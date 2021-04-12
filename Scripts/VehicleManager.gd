extends Node

export(NodePath) var vehiclePath
onready var vehicle_scene = load("res://Tanks/PzIV/PanzerIV.tscn") #Should be dynamic
onready var FloorFinder = $FloorFinder
onready var NM = get_node("../NetworkManager")
onready var vehicle : RigidBody = vehicle_scene.instance()
#onready var other_vehicle : RigidBody = vehicle_scene.instance()
var vehicleStartTransform : Transform
var tanks = []
var timer:float = 0.0
#var players = {}

var start = [Vector3(20,0,-12), Vector3(-12,0,-12),Vector3(6,0,-16),Vector3(14,0,-16),Vector3(14,0,-8)] #simple solution

var camrig #do everything to do with this differently

func _ready():
	camrig = get_parent().get_node("CameraRig")
	randomize()
	
#	get_parent().call_deferred("add_child", vehicle)
#	vehicle = get_node(vehiclePath)	
	

func _process(_delta):
	timer += _delta
	if timer > 0.1 and GameState.DriverID.has(GameState.tank): #not a good solution
		if GameState.DriverID[GameState.tank] == get_tree().get_network_unique_id():
#		if GameState.role == GameState.Role.Driver:
			rpc("set_pos", vehicle.transform, GameState.tank)
		if GameState.role == GameState.Role.Gunner:
			rpc("set_tur", vehicle.get_node("Visuals/turret").rotation,vehicle.get_node("Visuals/turret/gun").rotation, str(GameState.tank) )
#		add_random_tank()
		timer -= 0.1
	if Input.is_action_just_pressed("reset_vehicle"):
		reset_tank()

func reset_tank():		
	vehicle.linear_velocity = Vector3()
	vehicle.angular_velocity = Vector3()
#		vehicle.global_transform = vehicleStartTransform
	FloorFinder.find_floor(vehicle,vehicle.transform.origin)
	vehicle.rotate_y(PI)
		

func start():
	for i in tanks:
		i.queue_free() #delete intro tanks
	GameState.setup_debug() #fix this, make it optional
	vehicle.external_only = false
	get_parent().add_child(vehicle)
	
	get_parent().remove_child(camrig) #fix it
	vehicle.add_child(camrig)
	camrig.canrotx = true
	
#	vehicle.translation = start[GameState.tank]
	vehicle.auto = false #set manual control
	if GameState.role == GameState.Role.Driver:
		FloorFinder.find_floor(vehicle,start[GameState.tank])
#	else:
#		vehicle.mode = RigidBody.MODE_KINEMATIC
	vehicle.transform.origin += vehicle.transform.basis.y #Fix a weird bug
	vehicle.rotate_y(PI) #shouldnt be fixed
	vehicle.next_transform(vehicle.transform)
#	players[get_tree().get_network_unique_id()] = vehicle #dont think this is used???
#	if GameState.role == GameState.Role.Driver:
#		vehicle.name = str(get_tree().get_network_unique_id()) #set tank name to id as this is driver
#	else:
#		vehicle.name = str(GameState.DriverID[GameState.tank]) #set tank name to id of driver
	vehicle.VehicleMan = self #dont think this is a good idea
	vehicle.name = str(GameState.tank)
	
	vehicleStartTransform = vehicle.global_transform
#	$"../CameraRig"._camTarget = vehicle #give cam target
#	$"../CameraRig".canrotx = true #make cam rotatable on x
	$"../DebugUI".enable()
	#add additional vehicles for testing
	rpc("get_remote_tanks") #get remote tanks
	if GameState.role == GameState.Role.Driver: #dont add tanks if this is not driver
		rpc("add_tank", vehicle.translation, GameState.tank) #only add tanks if this is this driver
	return
#
#remote func new_tank(t):
	

remote func get_remote_tanks():
#	print(GameState.role)
	if GameState.role == GameState.Role.Driver or GameState.DriverID[GameState.tank] == get_tree().get_network_unique_id(): #only for drivers
		var nid = get_tree().get_rpc_sender_id()
		rpc_id(nid, "add_tank", vehicle.translation, GameState.tank)

remote func add_tank(t,tid):
#	print("starting remote tank")
	if get_parent().has_node(str(tid)): #Dont add tank if one exists
		return
	print(tid, GameState.tank)
	if not tid == GameState.tank: #if adding tank is the current drivers tank do no add
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
#		tank.name = str(get_tree().get_rpc_sender_id())
		tank.name = str(tid)
		tank.auto = false
		tank.mode = RigidBody.MODE_KINEMATIC
#		tank.VehicleMan = self
#		tank.translation = t#start[NM.players.keys().find(get_tree().get_network_unique_id())] #not correct
#		FloorFinder.find_floor(tank,start[GameState.tank])
		
#		tank.rotate_y(-PI/2) #shouldnt be fixed
		tank.next_transform(tank.transform)
		tank.get_node("Players").queue_free()

func load_intro_tanks():
	for i in range(10):
		var tank = vehicle_scene.instance()
		get_parent().add_child(tank)
		tank.rotate_y(-PI/2)
		tank.VehicleMan = self
		tanks.append(tank)
	
#	$"../CameraRig"._camTarget = tanks[rand_range(0,tanks.size())]
#	var data = FloorFinder.find_floor()
#	tanks[0].transform.basis.y = data[1]
#	tanks[0].transform = Transform.looking_at(-data[1],Vector3(0,1,0).rotated(Vector3(0,0,0),PI/2))
#	var tsf = Transform.looking_at(-data[1],Vector3(0,1,0))
#	tsf = tsf.rotated(tsf.basis.x,PI/2)
	
#	tanks[0].transform = FloorFinder.find_floor(tanks[0])
	for t in tanks:
		FloorFinder.find_floor(t)
#	tanks[0].transform.origin = data[0] + tsf.basis.y/10
#	tanks[0].next_transform(tanks[0].transform)
#	tanks[1].translation = Vector3(6,0.5,-12)
#	tanks[2].translation = Vector3(14,0.5,-12)
#
#	tanks[3].translation = Vector3(-10,0.5,-16)
#	tanks[4].translation = Vector3(-2,0.5,-16)
#	tanks[5].translation = Vector3(6,0.5,-16)
#	tanks[6].translation = Vector3(14,0.5,-16)
#
#	tanks[7].translation = Vector3(-10,0.5,-8)
#	tanks[8].translation = Vector3(-2,0.5,-8)
#	tanks[9].translation = Vector3(6,0.5,-8)
#	tanks[10].translation = Vector3(14,0.5,-8)
	
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

remote func set_pos(t,id): #needs a re-wrtie all this
#	var sid = str(get_tree().get_rpc_sender_id())
#	sid = str(GameState.tank)
	if get_parent().has_node(str(id)):
		get_parent().get_node(str(id)).next_transform(t)
#	other_vehicle.transform = t
	
remote func fire(id,number):
	get_parent().get_node(id).get_node("TurretController").fire(get_tree().get_rpc_sender_id(),number,false)

