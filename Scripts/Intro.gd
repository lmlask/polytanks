extends CanvasLayer
class_name Intro #intro? rename this

var gameRoot:gameRoot
onready var Grid = $Panel/VBoxContainer/LobbyGrid
onready var Host = $Panel/VBoxContainer/HBoxContainer/Host
onready var Join = $Panel/VBoxContainer/HBoxContainer/Join
onready var IPadd = $Panel/VBoxContainer/HBoxContainer/IP
onready var Start = $Panel/VBoxContainer/HBoxContainer/Start
onready var Status = $Panel/VBoxContainer/Status
onready var Map = $Panel/VBoxContainer/Map

func _ready():
	set_status("")
	enable_options()
	Map.hide()
	pass

func _on_Start_pressed():
#	GameState.tank = Grid.selected[0]
#	GameState.role = Grid.selected[1]
	if get_tree().is_network_server():
		GameState.map = Map.selected
	elif not GameState.hostInGame:
		set_status("Host must join first")
		return
	if GameState.role == GameState.Role.Driver:
		GameState.rpc("set_driver_id", GameState.tank, get_tree().get_network_unique_id())
		setup_game()
	else:
		print(GameState.DriverID)
		print(GameState.tank)
		if GameState.DriverID.has(GameState.tank):
			setup_game()
		else:
			set_status("Driver must join first")

func setup_game():
	GameState.rpc("set_roles", GameState.tank,GameState.role,get_tree().get_network_unique_id())
	GameState.hide_mouse()
	$Panel.hide()
	GameState.InGame = true
	if get_tree().is_network_server():
		GameState.rpc("set_hostInGame", GameState.InGame, GameState.map)
	gameRoot.Map.load_map(GameState.map)
	gameRoot.VehicleManager.start()
	

func _on_Join_pressed():
	gameRoot.NetworkManager.join_host()


func _on_Host_pressed():
#	Start.disabled = true
	gameRoot.NetworkManager.setup_host()
	Map.show()

func set_status(msg):
	Status.text = str(msg)

func disable_options():
	Host.disabled = true
	Join.disabled = true
	Start.disabled = false
	Grid.set_all_roles(false)

func enable_options():
	Host.disabled = false
	Join.disabled = false
	Start.disabled = true
	Grid.set_all_roles(true)

func get_ip():
	return IPadd.text
