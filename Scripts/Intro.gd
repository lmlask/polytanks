extends CanvasLayer
class_name Intro #intro? rename this

var gameRoot:gameRoot
onready var Grid = $Panel/VBoxContainer/LobbyGrid
onready var Host = $Panel/VBoxContainer/HBoxContainer/Host
onready var Join = $Panel/VBoxContainer/HBoxContainer/Join
onready var IPadd = $Panel/VBoxContainer/HBoxContainer/IP
onready var Start = $Panel/VBoxContainer/HBoxContainer/Start
onready var Status = $Panel/VBoxContainer/Status

func _ready():
	set_status("")
	enable_options()
	pass

func _on_Start_pressed():
	GameState.tank = Grid.selected[0]
	GameState.role = Grid.selected[1]
	if GameState.role == GameState.Role.Driver:
		GameState.rpc("set_driver_id", Grid.selected[0], get_tree().get_network_unique_id())
		gameRoot.VehicleManager.start()
		GameState.hide_mouse()
		$Panel.hide()
		GameState.InGame = true
	else:
		print(GameState.DriverID)
		print(Grid.selected[0])
		if GameState.DriverID.has(Grid.selected[0]):
			gameRoot.VehicleManager.start()
			GameState.hide_mouse()
			$Panel.hide()
			GameState.InGame = true
		else:
			set_status("Driver must join first")
	

func _on_Join_pressed():
	gameRoot.NetworkManager.join_host()


func _on_Host_pressed():
#	Start.disabled = true
	gameRoot.NetworkManager.setup_host()

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
