extends MeshInstance

# public variables
export(NodePath) var parentBodyPath
export var wheelSpeedScaling : float = 1.0
export var sprocketSpeedScaling : float = 1.6
export var idlerSpeedScaling : float = 1.5
export var trackUVScaling : float = 1.0

# private variables
var roadWheels : Array
var sprocket : MeshInstance
var idler : MeshInstance
var trackMat : SpatialMaterial
var parentBody : RigidBody
var lastPos : Vector3 = Vector3()

func _ready() -> void:
	# setup references
	if self.name ==  "trackL":
		roadWheels = get_parent().get_parent().get_parent().get_parent().get_node("Wheels/Left").get_children()
		sprocket = get_parent().get_parent().get_parent().get_parent().get_node("SpecialWheels/sprocketL")
		idler = get_parent().get_parent().get_parent().get_parent().get_node("SpecialWheels/idlerL")
	else:
		roadWheels = get_parent().get_parent().get_parent().get_parent().get_node("Wheels/Right").get_children()
		sprocket = get_parent().get_parent().get_parent().get_parent().get_node("SpecialWheels/sprocketR")
		idler = get_parent().get_parent().get_parent().get_parent().get_node("SpecialWheels/idlerR")
	trackMat = mesh.surface_get_material(0)
	parentBody = get_parent().get_parent().get_parent().get_parent()

func _physics_process(delta) -> void:
	# obtain velocity of the track
	var instantV = (global_transform.origin - lastPos) / delta
	var ZVel = global_transform.basis.xform_inv(instantV).z
	lastPos = global_transform.origin
	
	
	#forward
	if ZVel > 0.7:
		animate(ZVel, delta)
	elif ZVel < -1:
		animate(ZVel, delta)
	else:
		if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
			animate(ZVel, delta)


func animate(ZVel, delta):
	# animate wheels
	for wheel in roadWheels:
		wheel.rotate_x(ZVel * wheelSpeedScaling * delta)
		
	# animate drive sprocket and idler
	sprocket.rotate_x(ZVel * sprocketSpeedScaling * delta)
	idler.rotate_x(ZVel * idlerSpeedScaling * delta)
	
	# animate track texture
	trackMat.uv1_offset.y += (ZVel * trackUVScaling) * delta
	
	# clamp UV offset of tracks	
	if trackMat.uv1_offset.y > 1.0 or trackMat.uv1_offset.y < -1.0:
		trackMat.uv1_offset.y = 0.0
