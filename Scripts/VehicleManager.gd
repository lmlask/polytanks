extends Node
class_name ManagerVehicle

export(NodePath) var vehiclePath
#onready var vehicle_scene = load("res://Tanks/PzIV/PanzerIV.tscn") #Should be dynamic
onready var FloorFinder = $FloorFinder
onready var NM = get_node("../NetworkManager")
onready var vehicle:PanzerIV# = vehicle_scene.instance()
#onready var other_vehicle : RigidBody = vehicle_scene.instance()
var vehicleStartTransform : Transform
var tanks = []
var timer:float = 0.0
#var players = {}

var start_pos = [Vector3(20,0,-12), Vector3(-12,0,-12),Vector3(6,0,-16),Vector3(14,0,-16),Vector3(14,0,-8)] #simple solution

#var camrig #do everything to do with this differently

func _ready():
#	camrig = get_parent().get_node("CameraRig")
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
			rpc("set_tur", vehicle.Turret.rotation,vehicle.Gun.rotation, str(GameState.tank) )
#		add_random_tank()
		timer -= 0.1
	if Input.is_action_just_pressed("reset_vehicle"):
		reset_tank(vehicle)

	#add planes
	if randf() < 0.01: #Randome plane random direction
		var stuka = R.Stuka.instance()
		stuka.translation = Vector3(rand_range(-1000,1000),100,rand_range(-1000,1000))
		R.VPlanes.add_child(stuka)
		var opaltruck = R.OpalTruck.instance()
		opaltruck.translation = Vector3(rand_range(-100,100),0,rand_range(-100,100))
		R.VWheeled.add_child(opaltruck)

func reset_tank(v): #should be part of the vehicle
	v.linear_velocity = Vector3.ZERO
	v.angular_velocity = Vector3.ZERO
	FloorFinder.find_floor(v,v.transform.origin)
#	v.rotate_y(PI)
#	v.transform.origin += v.transform.basis.y
		

func start():
	R.Map.load_map(GameState.map,start_pos[GameState.tank])
	vehicle = R.VTPzIV.instance()
	if tanks.size() > 0:
		for i in tanks:
			i.queue_free() #delete intro tanks
		tanks.clear()
	GameState.setup_debug() #fix this, make it optional
	vehicle.external_only = false
	R.VTanks.add_child(vehicle)
	
#	get_parent().remove_child(camrig) #fix it
	var cam = R.CamExt.instance()
	vehicle.add_child(cam)
	GameState.CamActive = cam
	cam.canrotx = true
	
#	vehicle.translation = start[GameState.tank]
	vehicle.auto = false #set manual control
	if GameState.role == GameState.Role.Driver:
		FloorFinder.find_floor(vehicle,start_pos[GameState.tank])
#	else:
#		vehicle.mode = RigidBody.MODE_KINEMATIC
	vehicle.transform.origin += vehicle.transform.basis.y #Fix a weird bug and/or normals are not calcuated correctly
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
	if R.VTanks.has_node(str(tid)): #Dont add tank if one exists
		return
	print(tid, GameState.tank)
	if not tid == GameState.tank: #if adding tank is the current drivers tank do no add
		var tank = R.VTPzIV.instance()
		R.VTanks.add_child(tank)
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
	for i in range(5):
		add_intro_tank()
	
#	$"../CameraRig"._camTarget = tanks[rand_range(0,tanks.size())]
	var cam = R.CamExt.instance()
	tanks[rand_range(0,tanks.size())].add_child(cam)
	cam.canrotx = false
	
func add_intro_tank():
	if tanks.size() < 20: #only add tanks when tanks exists, ie game has started
		var tank = R.VTPzIV.instance()
		R.VTanks.add_child(tank)
#		tank.rotate_y(-PI/2)
		tank.VehicleMan = self
		FloorFinder.find_floor(tank)
		tanks.append(tank)

func delete_tank(t):
	t.queue_free()
	tanks.erase(t)

#Thinking I should have all vehicles in the some folder with a prefix
#Re-write it later once different things are added

remote func set_tur(tr,te,id): #set turrent rotation, change to work like tank transform
	if R.VTanks.has_node(id):
		R.VTanks.get_node(id).Turret.rotation = tr
		R.VTanks.get_node(id).Gun.rotation = te

remote func set_pos(t,id): #needs a re-wrtie all this
#	var sid = str(get_tree().get_rpc_sender_id())
#	sid = str(GameState.tank)
	if R.VTanks.has_node(str(id)):
		R.VTanks.get_node(str(id)).next_transform(t)
#	other_vehicle.transform = t
	
remote func fire(id,number):
	R.VTanks.get_node(id).get_node("TurretController").fire(get_tree().get_rpc_sender_id(),number,false)

