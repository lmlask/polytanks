extends Spatial
class_name Editor

onready var panel = $Editor/Panel
onready var paintPanel = $Editor/PaintPanel
onready var menu = $Editor/Menu
onready var site_button = $Editor/Panel/HBoxContainer/VSplitContainer/ScrollContainer/VBoxContainer/SiteButton
onready var item_button = $Editor/Panel/HBoxContainer/VSplitContainer2/ScrollContainer/VBoxContainer/ItemButton
onready var loc_button = $Editor/Panel/HBoxContainer/VSplitContainer3/ScrollContainer/VBoxContainer/LocButton
onready var MapLabel = $Editor/Panel/Map
onready var SiteLabel = $Editor/Panel/Site
onready var ItemsButton = $Editor/ItemsButton
onready var PaintColor = paintPanel.get_node("ColorPicker")
onready var ModeLabel = $Editor/ModeLabel

#onready var terrainmmi = [] #To be fixed later, POC

var enabled = false
var move_fwd = 0.0
var move_side = 0.0
var move_elev = 0.0
var move:Vector3 = Vector3.ZERO
var selected:Spatial = null

var site = null

var move_speed = 25.0
var rot_speed = 150.0
var paint = true #default to be false for not placing items
var is_painting = false 
var paint_pos = Vector3.ZERO
var paint_event
#var paintMode = false #default is to be true painting
enum paintModes {AREA,TERRAIN,ENV}
var paintMode = 0
var pressure:float = 0.0

var timer = 0.0
var delay = 0.25

signal editor_state

#var sites = {} #to be loaded from a file

func _ready():
	panel.hide()
	paintPanel.hide()
	$Editor/Enabled.hide()
	ModeLabel.hide()
	set_process(false)
	set_process_input(false)
	
#	var file = File.new()
#	if not file.file_exists(R.sitesfile):
#		return
#	file.open(R.sitesfile, File.READ)
#	sites = file.get_var()
	for i in R.Map.sites:
		site_button.add(R.Map.sites[i], i)
	for i in R.Items:
		ItemsButton.add_item(R.Items[i][1],i)
#	for i in R.TerrainMMI.get_children():
#		terrainmmi.append(i)
#		i.multimesh.instance_count = 9999
	
	
func _input(event):
	if not enabled:
		return
	if Input.is_action_just_pressed("F4"):
		get_tree().set_input_as_handled()
		if not paint:
			panel.visible = !panel.visible
		else:
			paintPanel.visible = !paintPanel.visible
		GameState.show_mouse()
#		R.Map.update_locations()
#		R.Map.update_items()
	if Input.is_action_just_pressed("F3"):
		get_tree().set_input_as_handled()
		enabled = false
		emit_signal("editor_state",enabled)
		$Editor/Enabled.hide()
		ModeLabel.hide()
		set_process(enabled)
		set_process_input(enabled)
		GameState.CamActive._cam.current = true #would imply _cam is consistant for all cams
		R.Map.remove_locations()
#		R.Map.remove_items()
		R.Map.add_items()
		selected = null
		return
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_F5) and selected:
			get_tree().set_input_as_handled()
			if selected.has_method("show_cam"):
				selected.show_cam()
				var _err = selected.connect("tree_exited",self,"unselect")
	if event is InputEventMouseMotion:
		if GameState.mouseHidden:
	#		rotate_y(event.relative.x/100.0)
			rotate(Basis.IDENTITY.y, -event.relative.x/rot_speed)
			rotation.x = clamp(rotation.x - event.relative.y /rot_speed, -PI/2, PI/2)
		elif is_painting:
			var result = get_ground(event.position)
			if result.has("collider"):
				paint_pos = result.position
#				if event.relative == Vector2(0,0):
#					pressure = event.pressure
				
			
#			var position = event.position
#			var from = $Camera.project_ray_origin(position)
#			var to = from + $Camera.project_ray_normal(position) * 1000
#			var space_state = get_world().direct_space_state
#			var result = space_state.intersect_ray(from,to)
#			print(result.collider.owner)
			
	elif event is InputEventKey:
		move.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
		move.x = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
		move.y = Input.get_action_strength("gear_down") - Input.get_action_strength("gear_up")
		if not move == Vector3.ZERO:
			get_tree().set_input_as_handled()
		if Input.is_action_pressed("reset_vehicle"): #same action does multiple things
			if paint:
				R.Paint.update_texture()
				ModeLabel.text = "Mode:Sites"
			else:
				_on_Mode_toggled(paintMode)
			paint = !paint
	elif event is InputEventMouseButton:
		if event.is_action_pressed("cam_zoom_in"):
			move_speed = min(move_speed * 1.5, 500.0)
		if event.is_action_pressed("cam_zoom_out"):
			move_speed = max(move_speed / 1.5, 10.0)
		if event.is_action_pressed("action") and not panel.visible:
			var result = get_ground(event.position)
#			print(result)
			if result.has("collider"):
				if not paint:
					if selected:
						R.Map.update_item(selected)
					if not result.collider.owner == null:
						if not result.collider.owner.is_in_group("terrain"):
							selected = result.collider.owner
					print(result)
					
				elif not paintPanel.visible:
					if paintMode == paintModes.TERRAIN or paintMode == paintModes.ENV:
						is_painting = true
					elif not result.collider.owner == null:
						if result.collider.owner.is_in_group("terrain"):
							R.Paint.area(result.position)
					elif result.collider.is_in_group("area_handle"):
						R.Paint.handle_select(result.collider)
					
		elif Input.is_action_just_released("action"):
			is_painting = false
			R.Paint.update_texture()
			R.Paint.update_env()
	
	if enabled and not (panel.visible or paintPanel.visible or event.is_action_pressed("ui_cancel") or paint): #only exists to not handle showing mouse so you can exit game
		get_tree().set_input_as_handled()

func unselect():
	selected = null

#func add_tree():
#	var l = get_ground(event)
#	print(l)

func get_ground(position):
	var from = $Camera.project_ray_origin(position)
	var to = from + $Camera.project_ray_normal(position) * 10000
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(from,to)

func _process(delta):
	if GameState.mouseHidden:
		transform.origin -= transform.basis.z * move.z * delta * move_speed
		transform.origin -= transform.basis.x * move.x * delta * move_speed
		transform.origin -= transform.basis.y * move.y * delta * move_speed
	elif selected:
		if selected.is_in_group("loc"):
			selected.transform.origin -= transform.basis.x * move.x * delta * move_speed
			selected.transform.origin -= transform.basis.z * move.z * delta * move_speed
		elif selected.is_in_group("item"):
			selected.transform.origin -= transform.basis.x * move.rotated(Vector3.UP, -selected.get_parent().rotation.y-PI/2).x * delta * move_speed
			selected.transform.origin -= transform.basis.z * move.rotated(Vector3.UP, -selected.get_parent().rotation.y-PI/2).z * delta * move_speed
		if not (selected.is_in_group("plane") or selected.is_in_group("truck")):
			selected.get_child(0).rotation.y += move.y * delta * move_speed / 10 #dont use get_child(0) fix it!!!
			R.FloorFinder.find_floor2(selected)
		
	timer += delta
	if timer > delay and $Camera.current:
		timer -= delay
		R.Map.check_area(global_transform.origin)
		GameState.view_location = global_transform.origin #easy fix, fix it
	if is_painting:
		if paintMode == paintModes.TERRAIN or paintMode == paintModes.ENV:
			R.Paint.paint(paint_pos,paintMode)
		else:
			R.Paint.road(paint_pos)


func _unhandled_key_input(event): #Trying something different
	if event.is_action_pressed("F3") and not event.echo and not enabled:
		print("F3 pressed")
		enabled = true
		emit_signal("editor_state",enabled)
		$Editor/Enabled.show()
		ModeLabel.show()
		set_process(enabled)
		set_process_input(enabled)
		GameState.hide_mouse()
		$Camera.current = true
		global_transform = GameState.CamActive._cam.global_transform #ehhhh _cam?
		panel.hide()
		MapLabel.text = "Map: " + R.height_map[R.Map.map][1] + "-" + str(R.Map.map)
		R.Map.locations_visibile(true)

func _on_Save_pressed():
	var file = File.new()
	file.open(R.sitesfile, File.WRITE)
	file.store_32(R.Map.sitesID)
	file.store_var(R.Map.sites)
	file.close()
	file.open(R.itemsfile, File.WRITE)
	file.store_32(R.Map.itemsID)
	file.store_var(R.Map.items)
	file.close()
	file.open(R.locsfile, File.WRITE)
	file.store_32(R.Map.locsID)
	file.store_var(R.Map.locations)
	file.close()

func _on_SiteAdd_pressed():
	var default = "New Site"
	R.Map.sitesID += 1
	site_button.add(default, R.Map.sitesID)
	R.Map.sites[R.Map.sitesID] = default
#	R.Map.add_site(default)

func _on_ItemAdd_pressed():
	if R.Map.site_selected == -1:
		print("Select a site first")
		return
	ItemsButton.show()

func _on_ItemsButton_item_selected(index):
	var id = ItemsButton.get_item_id(index)
	ItemsButton.hide()
	ItemsButton.selected= 0
	R.Map.itemsID += 1
	item_button.add(R.Items[id][1], R.Map.itemsID)
	R.Map.items[R.Map.itemsID] = [R.Map.site_selected,id,Vector2.ZERO,0]
#	print(R.Map.items)
	
func reload_items(id):
	clear_items()
	for i in R.Map.items:
		if R.Map.items[i][0] == id:
			item_button.add(R.Items[R.Map.items[i][1]][1],i)
	for i in R.Map.locations:
		if R.Map.locations[i][0] == R.Map.map and R.Map.locations[i][1] == R.Map.site_selected:
			loc_button.add(R.Map.locations[i][2],i)

func clear_items():
	for i in item_button.get_parent().get_children():
		if i.visible:
			i.queue_free()
	for i in loc_button.get_parent().get_children():
		if i.visible:
			i.queue_free()

func _on_LocAdd_pressed():
	if R.Map.site_selected == -1:
		print("Select a site first")
		return
	var default = "New Location"
	R.Map.locsID += 1
	loc_button.add(default, R.Map.locsID)
	var o = transform.origin - transform.basis.z * 100
	R.Map.locations[R.Map.locsID] = [R.Map.map, R.Map.site_selected, default, Vector2(o.x,o.z),0]
#	print(R.Map.locations[R.Map.locsID])

func _on_Mode_toggled(button_pressed):
	paintMode += 1
	paintMode = wrapi(paintMode,0,3)
	paintPanel.get_node("Mode").text = paintModes.keys()[paintMode]
	ModeLabel.text = "Mode:" + paintModes.keys()[paintMode]
	
