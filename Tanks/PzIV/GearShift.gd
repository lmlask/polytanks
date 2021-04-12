extends MeshInstance


onready var engine = owner.engine
onready var tween = owner.get_node("Interior/Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func shift(nextGear):
	var transl
	if nextGear == 1 or nextGear == 2 or nextGear == -1:
		transl = 0.338
	elif nextGear == 3 or nextGear == 4 or nextGear == 0:
		transl = 0.323
	elif nextGear == 5 or nextGear == 6:
		transl = 0.308
		
	var rot
	if nextGear != 0 and nextGear % 2 == 0:
		rot = -10
	elif nextGear == 0:
		rot = 0
	else:
		rot = 10
		
	var trans = Tween.TRANS_QUAD
	
	#Put in neutral rotation
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(0, 0, 0), 0.3, trans, Tween.EASE_IN)
	tween.start()
	
	#Put in correct translation
	tween.interpolate_property(self, "translation", translation, Vector3(transl, -0.374, 1.016), 0.3, trans, Tween.EASE_IN)
	tween.start()
	
	#Put in correct rotation
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, Vector3(rot, 0, 0), 0.3, trans, Tween.EASE_IN)
	tween.start()
	

#Gear shift procedure
#1. Put in neutral rotation
#2. Put in correct x transform
#3. Put in correct rotation


#Gears 1 and 2:
#x = 0.338
#3 and 4:
#x = 0.323
#5 and 6:
#x = 0.308

#Odd gears: rotation_degrees.x = 15
#Even gears: rotation_degrees.x = -15
#Neutral: 0


