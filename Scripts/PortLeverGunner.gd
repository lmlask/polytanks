extends Area

var state = "closed"
onready var lever = owner.get_node("Interior/TurretInterior/Dynamic/LeverGunner")
onready var shape = $CollisionShape
onready var port = owner.get_node("Visuals/Turret/GunnerFrontPort")
onready var tween = owner.get_node("Interior/Tween")
var indicator = "hand"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func interact():
	if state == "closed":
		tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(-40, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees", lever.rotation_degrees, Vector3(-40, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(port, "rotation_degrees", port.rotation_degrees, Vector3(-70, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "open"
	elif state == "open":
		tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(shape, "rotation_degrees", lever.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(port, "rotation_degrees", port.rotation_degrees, Vector3(0, 0, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "closed"
