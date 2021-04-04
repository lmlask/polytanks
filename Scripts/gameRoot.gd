extends Node
class_name gameRoot

onready var VehicleManager = $VehicleManager
onready var NetworkManager = $NetworkManager

func _ready():
	$CanvasLayer/Intro.gameRoot = self
	$NetworkManager.intro = $CanvasLayer/Intro
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
