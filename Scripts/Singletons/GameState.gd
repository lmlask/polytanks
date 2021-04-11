extends Node

# global vars
var mouseHidden : bool = false
var debugMode : bool = false
var DebugUI = load("res://Scenes/DebugUI.tscn").instance()
onready var gameRoot = get_node("/root/gameRoot")
onready var RoleSelect = gameRoot.get_node("Roles")
enum Mode {Host, Client}
enum Role {None, Driver, Gunner}
var mode
var role:int
var tank:int
var InGame = false
remote var hostInGame = false #Maybe consolidate these into a dictionary
remote var DriverID = {}
var roles = {}
remote var map
remote var wind_vector = Vector2.ZERO
var speed:float = 1
var ShellCam = false
var WindView = false

func _ready() -> void:
	pass
#	gameRoot.add_child(DebugUI) #make optional
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

remotesync func set_roles(t,r,id):
	if not t == tank:
		return
	for zr in roles:
		if roles[zr] == id:
			roles.erase(zr)
	roles[r] = id
	if r == Role.Driver:
		rpc("set_driver_id", tank, id)
	if role == Role.Driver and not id == DriverID[tank]:
		rpc_id(id, "update_roles", roles)
	RoleSelect.setup_panel()
	
remote func remove_role(id):
	for i in roles:
		if roles[i] == id:
			roles.erase(i)

master func send_game_data():
	rset("hostInGame", hostInGame)
	rset("map", map)
	rset("wind_vector", wind_vector)

func change_roles(i):
	print("try to change roles")
#	if role == Role.Driver:
#		roles.erase(Role.Driver)
#		role = Role.None
	if roles.has(i):
		print("role taken")
		return
	rpc("set_roles",tank,i,get_tree().get_network_unique_id())
	role = i
	gameRoot.get_node("Lobby").Grid.rpc("disable_role", true)

remote func update_roles(r):
	roles = r

remotesync func set_driver_id(tank, id):
#	print("set driver",tank,id)
#	DriverID[tank] = id
#	if not role == Role.Driver:
#	var nid = str(get_tree().get_network_unique_id())
#	if DriverID.size() > 0 and DriverID.has(tank):
#		var node = gameRoot.find_node(str(DriverID[tank]),false,false)  #!!!! DONT DO THIS FIX IT
	#		print(node)
#		if node is RigidBody:#!!!! DONT DO THIS FIX IT
#			node.name = str(id) #This however is correct, I think
	#			print(node.name)
	DriverID[tank] = id
#	print(DriverID)

func setup_debug():
	gameRoot.add_child(DebugUI) #make optional

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if mouseHidden == true:
			show_mouse()
		else:
			hide_mouse()
	if event.is_action_pressed("debug_key"):
		if debugMode == true:
			debugMode = false
		else:
			debugMode = true
	if Input.is_action_just_pressed("F2") and InGame: #move to roles
		if gameRoot.VehicleManager.vehicle.engine.state == "OFF WARM" or true: #enum this
			RoleSelect.toggle()

func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	OS.window_fullscreen = true
	mouseHidden = true

func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	OS.window_fullscreen = false
	mouseHidden = false

#func _process(delta):
#	print(DriverID)
