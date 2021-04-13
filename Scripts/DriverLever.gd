extends Area

var state = "closed"
onready var lever = get_parent().get_parent().get_node("HullInterior/Dynamic/LeverDriver")
onready var shape = $CollisionShape
onready var sideport = get_parent().get_parent().get_parent().get_node("Visuals/Hull/HullSideportDriver")
onready var tween = get_parent().get_parent().get_node("Tween")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func interact():
	if state == "closed":
		tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, -12.391, 60), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(0, -12.696, 70), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "open"
	elif state == "open":
		tween.interpolate_property(lever, "rotation_degrees", lever.rotation_degrees, Vector3(0, -12.391, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.interpolate_property(sideport, "rotation_degrees", sideport.rotation_degrees, Vector3(0, -12.696, 0), 0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()
		state = "closed"
