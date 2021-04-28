extends Area

onready var tween = owner.get_node("Interior/Tween")
onready var top = owner.get_node("Interior/HullInterior/Dynamic/GyroIndicatorTop")
onready var top_mat = top.get_surface_material(0)
var interacting
var indicator = "hand"

func _ready():
	pass

func interact():
	if not interacting:
		interacting = true
		var target_offset = top_mat.uv1_offset.x + (1.0 / 12.0)
		tween.interpolate_property(top_mat, "uv1_offset", top_mat.uv1_offset, Vector3(target_offset, -0.052, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()

func _on_Tween_tween_completed(object, _key):
	if object == top_mat:
		interacting = false
