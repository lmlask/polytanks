extends Control
class_name Intro #intro? rename this

var gameRoot:gameRoot
onready var Grid = $Panel/LobbyGrid

func _ready():
	set_status("")
	enable_options()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Start_pressed():
	GameState.tank = Grid.selected[0]
	GameState.role = Grid.selected[1]
	gameRoot.VehicleManager.start()
	GameState.hide_mouse()
	hide()

func _on_Join_pressed():
	gameRoot.NetworkManager.join_host()


func _on_Host_pressed():
	$Panel/Start.disabled = false
	gameRoot.NetworkManager.setup_host()

func set_status(msg):
	$Panel/Status.text = str(msg)

func disable_options():
	$Panel/Host.disabled = true
	$Panel/Join.disabled = true
	$Panel/Start.disabled = false
	Grid.set_all_roles(false)

func enable_options():
	$Panel/Host.disabled = false
	$Panel/Join.disabled = false
	$Panel/Start.disabled = true
	Grid.set_all_roles(true)

func get_ip():
	return $Panel/IP.text
