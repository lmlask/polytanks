extends Control
class_name Intro #intro? rename this

var gameRoot:gameRoot

func _ready():
	set_status("")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	gameRoot.VehicleManager.start()
	GameState.hide_mouse()
	hide()

func _on_Join_pressed():
	gameRoot.NetworkManager.join_host()


func _on_Host_pressed():
	gameRoot.NetworkManager.setup_host()

func set_status(msg):
	$Panel/Status.text = str(msg)

func disable_options():
	$Panel/Host.disabled = true
	$Panel/Join.disabled = true
