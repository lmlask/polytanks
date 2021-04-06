extends Node
class_name gameRoot

onready var VehicleManager = $VehicleManager
onready var NetworkManager = $NetworkManager

func _ready():
	$Lobby/Intro.gameRoot = self
	$NetworkManager.intro = $Lobby/Intro
	VehicleManager.load_intro_tanks()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
