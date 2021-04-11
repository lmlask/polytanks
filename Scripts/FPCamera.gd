extends Spatial

export (NodePath) var target

export (float, 0.0, 2.0) var rotation_speed = PI/2

#role

export (String) var role

# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.005
export (bool) var invert_y = false
export (bool) var invert_x = false

# zoom settings

export (float) var max_zoom = 1.3
export (float) var min_zoom = 0.3
export (float) var max_zoom_gun = 1.3
export (float) var min_zoom_gun = 0.3
export (float) var max_zoom_mg = 1.3
export (float) var min_zoom_mg = 0.3
export (float, 0.05, 1.0) var zoom_speed = 0.09

# movement properties

export (Vector2) var max_movement

var zoom = 1
var default_sensivity = mouse_sensitivity
var default_transform
var target_offset_x = 0
var target_offset_y = 0
var true_offset = Vector2(0, 0)

#raycast
onready var ray = $OuterGimbal/InnerGimbal/ClippedCamera/RayCast
var aimedObject = null
var interact_areas = []

#modes
var mode = "pan"

func _ready():
	default_transform = global_transform

func _process(delta):
	applyOffset(target_offset_x, target_offset_y)
	
	#clamp rotation
	if mode == "pan":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -1, 1.4)
	elif mode == "port":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -0.15, 0.2)
		$OuterGimbal.rotation.y = clamp($OuterGimbal.rotation.y, -0.5, 0.5)
	
	#Apply zoom and sensivity
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov = lerp(get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov, 70 * zoom, 4*delta)
	mouse_sensitivity = default_sensivity * zoom * zoom

	#set target for portmode:
	if target:
		global_transform.origin = target.global_transform.origin
		
	lookatHandler()

func set_current():
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").current = true

func _input(event):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
		
	#Zoom input
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
		
	#Zoom clamping
	zoom = clamp(zoom, min_zoom, max_zoom)
		
	if event is InputEventMouseMotion:
		#camera movement
		if Input.is_action_pressed("cam_move") and (mode == "pan"):
			if event.relative.x != 0:
				var dir = 1 if invert_x else -1
				target_offset_x = dir * -event.relative.x * default_sensivity * 0.1
			if event.relative.y != 0:
				var dir = 1 if invert_y else -1
				target_offset_y = dir * event.relative.y * default_sensivity * 0.1
	
		elif mode == "pan":
			if event.relative.x != 0:
				var dir = 1 if invert_x else -1
				$OuterGimbal.rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)

			if event.relative.y != 0:
				var dir = 1 if invert_y else -1
				var y_rotation = clamp(event.relative.y, -30, 30)
				$OuterGimbal/InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)

func applyOffset(x, y):
	if mode == "pan":
		if (true_offset.x + x) >= max_movement.x or (true_offset.x + x) <= -max_movement.x:
			x = 0
		if (true_offset.y + y) >= max_movement.y or (true_offset.y + y) <= -max_movement.y:
			y = 0
		#translate camera
		translate(Vector3(x, y, 0))
		#update offset amount
		true_offset = Vector2(true_offset.x + x, true_offset.y + y)
		#reset target offset
		target_offset_x = 0
		target_offset_y = 0

func resetCamera():
	true_offset = Vector2(0, 0)
	target = null
	mode = "pan" 
	$OuterGimbal/InnerGimbal.rotation.x = 0
	$OuterGimbal.rotation.y = 0
	transform.origin = Vector3.ZERO
	$OuterGimbal/InnerGimbal/ClippedCamera.translation.z = 0
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov = 70

func togglePortMode(port, transY, rotY, rotX):
	if mode == "pan":
		mode = "port"
		target = "port"
		$OuterGimbal/InnerGimbal/ClippedCamera.translate(Vector3(0, 0, transY))
		$OuterGimbal.rotation_degrees.y = rotY
		$OuterGimbal/InnerGimbal.rotation_degrees.x = rotX
		true_offset = Vector2(0, 0)
	elif mode == "port":
		resetCamera()

func lookatHandler():
	if $OuterGimbal/InnerGimbal/ClippedCamera.current and (mode == "pan" or mode == "port") and interact_areas.has(ray.get_collider()):
		aimedObject = ray.get_collider()
	else:
		aimedObject = null
