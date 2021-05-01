extends MeshInstance

onready var turretController = owner.get_node("TurretController")
onready var gunControl = owner.get_node("Visuals/Turret/gun")
onready var barrel = owner.get_node("Visuals/Turret/gun/gunMesh/barrel")
onready var shape = owner.get_node("Interior/TurretInterior/LoaderClickables/LoaderBreechLever/CollisionShape")
onready var tween = owner.get_node("Interior/Tween")

func _process(_delta):
	#Elevation
	rotation.x = gunControl.rotation.x

func recoil():
	turretController.loaded = false
	tween.interpolate_property($Breech, "translation:z", $Breech.translation.z, -0.3, 0.15, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(0.15), "timeout")
	tween.interpolate_property($Breech, "translation:z", $Breech.translation.z, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(0.1), "timeout")
	open_breech()

func open_breech():
	tween.interpolate_property($Breech/BreechBlock, "translation:y", $Breech/BreechBlock.translation.y, -0.127, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property($Breech/BreechLever, "rotation_degrees:x", $Breech/BreechLever.rotation_degrees.x, -30, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(shape, "rotation_degrees:x", shape.rotation_degrees.x, -30, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(0.3), "timeout")
	turretController.locked = false
	shape.get_parent().state = "open"
	
