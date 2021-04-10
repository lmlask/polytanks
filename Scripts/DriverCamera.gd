extends Spatial

export (NodePath) var target

export (float, 0.0, 2.0) var rotation_speed = PI/2

#role

export (String) var role

# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.005
export (bool) var invert_y = false
export (bool) var invert_x = false
export (bool) var current = false

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

var rotation_target_x = 0
var rotation_target_y = 0

#raycast
onready var ray = $OuterGimbal/InnerGimbal/ClippedCamera/RayCast

#modes
var mode = "pan"

#aiming modes
onready var aimedPosMG = get_parent().get_parent().get_node("RadiomanControl/CameraMGPosition")
onready var aimedPosGun = get_parent().get_parent().get_parent().get_node("turret/GunnerControl/AimedCameraPosition")

func set_current():
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").current = true

func _ready():
	default_transform = global_transform

func get_input_keyboard(delta):
	# Rotate outer gimbal around y axis
	var y_rotation = 0
	$OuterGimbal.rotate_object_local(Vector3.UP, y_rotation * rotation_speed * delta)
	# Rotate inner gimbal around local x axis
	var x_rotation = 0
	x_rotation = -x_rotation if invert_y else x_rotation
	$OuterGimbal/InnerGimbal.rotate_object_local(Vector3.RIGHT, x_rotation * rotation_speed * delta)

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
	
		elif mode == "pan" or mode == "port" or mode == "mg":
			if event.relative.x != 0:
				var dir = 1 if invert_x else -1
				$OuterGimbal.rotate_object_local(Vector3.UP, dir * event.relative.x * mouse_sensitivity)
				if mode == "mg" and role == "radioman":
					get_parent().get_node("MG34").rotation_degrees.y = $OuterGimbal.rotation_degrees.y

			if event.relative.y != 0:
				var dir = 1 if invert_y else -1
				var y_rotation = clamp(event.relative.y, -30, 30)
				$OuterGimbal/InnerGimbal.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)
				if mode == "mg" and role == "radioman":
					get_parent().get_node("MG34").rotation.y = $OuterGimbal.rotation.y
					get_parent().get_node("MG34").rotation.x = -$OuterGimbal/InnerGimbal.rotation.x

func _process(delta):
	lookatHandler()
	applyOffset(target_offset_x, target_offset_y)
	
	#clamp rotation
	if mode == "pan":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -1, 1.4)
	elif mode == "port":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -0.15, 0.2)
		$OuterGimbal.rotation.y = clamp($OuterGimbal.rotation.y, -0.5, 0.5)
	elif mode == "mg":
		$OuterGimbal/InnerGimbal.rotation.x = clamp($OuterGimbal/InnerGimbal.rotation.x, -0.25, 0.25)
		$OuterGimbal.rotation.y = clamp($OuterGimbal.rotation.y, -0.25, 0.25)
	elif mode == "gun":
		$OuterGimbal/InnerGimbal.rotation.x = -get_parent().get_parent().get_parent().get_node("turret/GunnerControl/recoil_guard").rotation.x
		if Input.is_action_just_pressed("alt_action"):
			resetCamera()
	
	
	#Apply zoom and sensivity
	get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov = lerp(get_node("OuterGimbal/InnerGimbal/ClippedCamera").fov, 70 * zoom, 4*delta)
	mouse_sensitivity = default_sensivity * zoom * zoom

	#set target for portmode:
	if target:
		global_transform.origin = target.global_transform.origin
		

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
	rotation_degrees.y = -180
	true_offset = Vector2(0, 0)
	target = null
	mode = "pan" 
	$OuterGimbal/InnerGimbal.rotation.x = 0
	$OuterGimbal.rotation.y = 0
	global_transform.origin = get_parent().get_node("CameraDefaultPosition").global_transform.origin
	zoom = 1
	if role == "radioman":
		if get_parent().get_parent().get_node("RadiomanControl").mg_state == "raised":
			get_parent().get_parent().get_node("RadiomanControl").mg_state = "lowering"
			get_parent().get_node("MG34/mg_cloth_sfx").stop()
			get_parent().get_node("MG34/mg_cloth_sfx").stream = load("res://Sfx/cloth2.wav")
			get_parent().get_node("MG34/mg_cloth_sfx").play()
	$OuterGimbal/InnerGimbal/ClippedCamera.translation.z = 0

func togglePortMode(port):
	if mode == "pan":
		if port == get_parent().get_node("driver_visor_area"):
			mode = "port"
			target = port
			$OuterGimbal/InnerGimbal/ClippedCamera.translate(Vector3(0, 0, 0.2))
			true_offset = Vector2(0, 0)
		elif port == get_parent().get_node("driver_sideport_area") or port == get_parent().get_node("radioman_sideport_area"):
			if role == "driver":
				rotation_degrees.y = -100
			elif role == "radioman":
				rotation_degrees.y = 100
			mode = "port"
			target = port
			$OuterGimbal/InnerGimbal/ClippedCamera.translate(Vector3(0, 0, 0.2))
			$OuterGimbal/InnerGimbal.rotation_degrees.x = 0
			true_offset = Vector2(0, 0)
		elif port == get_parent().get_node("gunner_sideport_area"):
			if role == "gunner":
				rotation_degrees.y = -80
			mode = "port"
			target = port
			$OuterGimbal/InnerGimbal/ClippedCamera.translate(Vector3(0, 0, 0.2))
			$OuterGimbal/InnerGimbal.rotation_degrees.x = 0
			true_offset = Vector2(0, 0)
			
	elif mode == "port":
		resetCamera()

func toggleRadioMG():
	if role == "radioman":
		mode = "transition"

func toggleGunnerSight():
	if role == "gunner":
		mode = "transition_gun"

func lookatHandler():
	pass
#	if (mode == "pan" or mode == "port"):
#	#Check the lookats
#		if role == "driver":
#			controlNode = get_parent().get_parent().get_node("DriverControl")
#			if ray.get_collider() == get_parent().get_node("driver_light_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_panel_light_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_visor_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_sideport_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_hatch_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_lever1_area"):
#				aimedObject = ray.get_collider()
#
#			elif ray.get_collider() == get_parent().get_node("driver_lever2_area"):
#				aimedObject = ray.get_collider()
#
#			else:
#				aimedObject = null
#
#
#	else:
#		aimedObject = null
