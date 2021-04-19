extends Area

var state = "closed"
onready var hatch = owner.get_node("Visuals/Hull/DriverHatch")
onready var camera = owner.get_node("Players/Driver/Camera")
onready var tween = owner.get_node("Interior/Tween")
var indicator = "hand"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func interact():
	if state == "closed":
		camera.tween(Vector3(0, 0.4, 0.10), 1.0, Tween.TRANS_CUBIC)
		tween.interpolate_property(hatch, "rotation_degrees", hatch.rotation_degrees, Vector3(179, 0, 0), 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "open"
		camera.mode = "hatch"
	elif state == "open":
		camera.tween(Vector3.ZERO, 1.0, Tween.TRANS_CUBIC)
		tween.interpolate_property(hatch, "rotation_degrees", hatch.rotation_degrees, Vector3(0, 0, 0), 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "closed"


func _on_Tween_tween_completed(object, key):
	if object == hatch:
		if hatch.rotation_degrees.x == 0:
			camera.mode = "pan"
