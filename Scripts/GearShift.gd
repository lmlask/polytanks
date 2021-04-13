extends MeshInstance

var transl
var rot
var trans
var complete_1 = false
var complete_2 = false
var complete_3 = false
var shifting = false
var time = 0.15

onready var engine = owner.engine
onready var tween = owner.get_node("Interior/Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	trans = Tween.TRANS_QUAD
	complete_1 = false
	complete_2 = false
	complete_3 = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shifting:
		pass

func shift(nextGear):
	shifting = true
	
	complete_1 = false
	complete_2 = false
	complete_3 = false
	
	if nextGear == 1 or nextGear == 2 or nextGear == -1:
		transl = 0.338
	elif nextGear == 3 or nextGear == 4 or nextGear == 0:
		transl = 0.323
	elif nextGear == 5 or nextGear == 6:
		transl = 0.308
		
	if nextGear != 0 and nextGear % 2 == 0:
		rot = -10
	elif nextGear == 0:
		rot = 0
	else:
		rot = 10
	
	step1(trans)


func step1(trans):
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(0, 0, 0), time, trans, Tween.EASE_IN_OUT)
	tween.start()
	
func step2():
	tween.interpolate_property(self, "translation", translation, Vector3(transl, -0.374, 1.016), time, trans, Tween.EASE_IN_OUT)
	tween.start()
	
func step3():
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(rot, 0, 0), time, trans, Tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	if object == self and key == ":rotation_degrees" and complete_1 == false:
		complete_1 = true
		step2()
	if object == self and key == ":translation" and complete_2 == false:
		complete_2 = true
		step3()
	if object == self and key == ":rotation_degrees" and complete_3 == false:
		complete_3 = true
		shifting = false
