extends MeshInstance

onready var turretController = owner.get_node("TurretController")
onready var gunControl = owner.get_node("Visuals/Turret/gun")
onready var barrel = owner.get_node("Visuals/Turret/gun/gunMesh/barrel")
onready var shape = owner.get_node("Interior/TurretInterior/LoaderClickables/LoaderBreechLever/CollisionShape")
onready var tween = owner.get_node("Interior/Tween")

func _process(delta):
	#Elevation
	rotation.x = gunControl.rotation.x
	
#	#Recoil code
##	print(state)
#	if state == "back":
#		$Breech.translation.z = -0.3
#		state = "return"
#	elif state == "return":
#		if $Breech.translation.z >= -0.01:
#			$Breech.translation.z = 0
#			state = "idle"
#			open_breech()
#		else:
#			$Breech.translation.z = lerp($Breech.translation.z, 0, delta*3)

func recoil():
	tween.interpolate_property($Breech, "translation:z", $Breech.translation.z, -0.3, 0.15, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.15), "timeout")
	tween.interpolate_property($Breech, "translation:z", $Breech.translation.z, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(0.1), "timeout")
	open_breech()

func open_breech():
	tween.interpolate_property($Breech/BreechBlock, "translation:y", $Breech/BreechBlock.translation.y, -0.127, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property($Breech/BreechLever, "rotation_degrees:x", $Breech/BreechLever.rotation_degrees.x, -30, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -30, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	shape.get_parent().state = "open"

func _on_Tween_tween_completed(object, key):
	if object == $Breech and key == ":translation:z" and $Breech.translation.z == -0.3:
		print("match")
