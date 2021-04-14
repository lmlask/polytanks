extends Spatial

# Control variables
export var maxPitch : float = 45
export var minPitch : float = -45
export var maxZoom : float = 20
export var minZoom : float = 4
export var zoomStep : float = 2
export var zoomYStep : float = 0.15
export var verticalSensitivity : float = 0.002
export var horizontalSensitivity : float = 0.002
export var camYOffset : float = 3.0
export var camLerpSpeed : float = 16.0
export(NodePath) var target

# Private variables
#onready var _camTarget : Spatial = $"../Map"
var _cam : ClippedCamera
var _curZoom : float = 0.0
var canrotx = false

func _ready() -> void:
	# Setup node references
#	_camTarget = get_node(target) #set by script
	_cam = get_node("Target/ClippedCamera")
	$Target.rotate_y(-PI/2)
	$Target.rotation.x = -PI/8
	
	# Setup camera position in rig
	_cam.translate(Vector3(0,camYOffset,maxZoom))
	_curZoom = maxZoom

func _input(event) -> void:
	if event is InputEventMouseMotion:
		# Rotate the rig around the target
		$Target.rotate_y(-event.relative.x * horizontalSensitivity)
		if canrotx:
			$Target.rotation.x = clamp($Target.rotation.x - event.relative.y * verticalSensitivity, deg2rad(minPitch), deg2rad(maxPitch))
		get_node("/root/gameRoot/ViewportContainer/View/GUI").set_compass($Target.transform.basis) #fix this camrig
		$Target.orthonormalize()
		
		
	if event is InputEventMouseButton:
		# Change zoom level on mouse wheel rotation
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP and _curZoom > minZoom:
				_curZoom -= zoomStep
				camYOffset -= zoomYStep
			if event.button_index == BUTTON_WHEEL_DOWN and _curZoom < maxZoom:
				_curZoom += zoomStep
				camYOffset += zoomYStep

func _process(delta) -> void:
#	return
	# zoom the camera accordingly
	global_transform.basis = Basis.IDENTITY
	_cam.set_translation(_cam.translation.linear_interpolate(Vector3(0,camYOffset,_curZoom),delta * camLerpSpeed))
	# set the position of the rig to follow the target

	return
#	set_translation(_camTarget.global_transform.origin)
