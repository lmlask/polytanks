extends Spatial

onready var panel = $Editor/Panel
onready var menu = $Editor/Menu
onready var site_button = $Editor/Panel/HBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/SiteButton
onready var MapLabel = $Editor/Panel/Map
onready var SiteLabel = $Editor/Panel/Site

var enabled = false
var move_fwd = 0.0
var move_side = 0.0
var move_elev = 0.0
var move:Vector3 = Vector3.ZERO
var selected:Spatial = null

var site = null

var move_speed = 25.0
var rot_speed = 250.0

var timer = 0.0
var delay = 0.25

#var sites = {} #to be loaded from a file


func _ready():
	panel.hide()
	set_process(false)
	set_process_input(false)
	
#	var file = File.new()
#	if not file.file_exists(R.sitesfile):
#		return
#	file.open(R.sitesfile, File.READ)
#	sites = file.get_var()
	for i in R.Map.sites:
		site_button.add(R.Map.sites[i], i)

func _input(event):
	if not event.is_action_pressed("ui_cancel") and not panel.visible: #only exists to not handle showing mouse so you can exit game
		get_tree().set_input_as_handled()
	if Input.is_action_just_pressed("F4"):
		panel.visible = !panel.visible
		R.Map.update_sites()
	if Input.is_action_just_pressed("F3"):
		enabled = false
		set_process(enabled)
		set_process_input(enabled)
		GameState.CamActive._cam.current = true #would imply _cam is consistant for all cams
		R.Map.remove_sites()
		return
	if event is InputEventMouseMotion:
		if GameState.mouseHidden:
	#		rotate_y(event.relative.x/100.0)
			rotate(Basis.IDENTITY.y, -event.relative.x/rot_speed)
			rotation.x = clamp(rotation.x - event.relative.y /rot_speed, -PI/2, PI/2)
		else:
			var position = event.position
			var from = $Camera.project_ray_origin(position)
			var to = from + $Camera.project_ray_normal(position) * 1000
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(from,to)
#			print(result.collider.owner)
			
	elif event is InputEventKey:
		move.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
		move.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
		move.y = Input.get_action_strength("gear_down") - Input.get_action_strength("gear_up")
	elif event is InputEventMouseButton:
		if event.is_action_pressed("cam_zoom_in"):
			move_speed = min(move_speed * 1.5, 500.0)
		if event.is_action_pressed("cam_zoom_out"):
			move_speed = max(move_speed / 1.5, 10.0)
		if event.is_action_pressed("action") and not panel.visible:
			var position = event.position
			var from = $Camera.project_ray_origin(position)
			var to = from + $Camera.project_ray_normal(position) * 1000
			var space_state = get_world().direct_space_state
			var result = space_state.intersect_ray(from,to)
			selected = result.collider.owner
			print(selected.name)

func _process(delta):
	if GameState.mouseHidden:
		transform.origin -= transform.basis.z * move.z * delta * move_speed
		transform.origin -= transform.basis.x * move.x * delta * move_speed
		transform.origin -= transform.basis.y * move.y * delta * move_speed
	elif selected:
		selected.transform.origin -= transform.basis.x * move.x * delta * move_speed
		selected.transform.origin -= transform.basis.z * move.z * delta * move_speed
		selected.get_child(0).rotation.y += move.y * delta * move_speed / 10 #dont use get_child(0) fix it!!!
		R.FloorFinder.find_floor2(selected, false)
	timer += delta
	if timer > delay:
		timer -= delay
		R.Map.check_area(global_transform.origin,true)


func _unhandled_key_input(event): #Trying something different
	if event.is_action_pressed("F3") and not event.echo and not enabled:
		print("F3 pressed")
		enabled = true
		set_process(enabled)
		set_process_input(enabled)
		GameState.hide_mouse()
		$Camera.current = true
		global_transform = GameState.CamActive._cam.global_transform #ehhhh _cam?
		panel.hide()
		MapLabel.text = "Map: " + R.Map.MapNode.height_map[R.Map.map][1]
#		R.Map.add_sites()

func _on_Save_pressed():
	var file = File.new()
	file.open(R.sitesfile, File.WRITE)
	file.store_32(R.Map.sitesID)
	file.store_var(R.Map.sites)
	file.close()

func _on_SiteAdd_pressed():
	var default = "New"
	R.Map.sitesID += 1
	site_button.add(default, R.Map.sitesID)
	R.Map.sites[R.Map.sitesID] = default
	R.Map.add_site(default)
