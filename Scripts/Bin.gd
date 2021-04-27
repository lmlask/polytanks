extends Area

export var ammo_code : String
export var type : String
var indicator = "hand"
var mesh
var camera

#Textures and scenes
var apc_tex = preload("res://Textures/Icons/APC.png")
var apcr_tex = preload("res://Textures/Icons/APCR.png")
var he_tex = preload("res://Textures/Icons/HE.png")
var heat_tex = preload("res://Textures/Icons/HEAT.png")
var smoke_tex = preload("res://Textures/Icons/dot.png")

var transp_mat = preload("res://Materials/transp_projectile.tres")

var apc = preload("res://Projectiles/PanzerIV/APC.tscn")
var apcr = preload("res://Projectiles/PanzerIV/APCR.tscn")
var he = preload("res://Projectiles/PanzerIV/HE.tscn")
var heat = preload("res://Projectiles/PanzerIV/HEAT.tscn")
var smoke = preload("res://Projectiles/PanzerIV/Smoke.tscn")

#Data
var ammo_positions : Dictionary
var ammo_types = {
	GameState.Ammo.None : null,
	GameState.Ammo.APC : apc,
	GameState.Ammo.APCR : apcr,
	GameState.Ammo.HE : he,
	GameState.Ammo.HEAT : heat,
	GameState.Ammo.Smoke : smoke,
}
var shell_array : Array
var positions_array : Array

var active = false
var last_active = false
var last_holding = false
var active_shell
var active_pos

var loader_camera
var tween
var held_shell_type = GameState.Ammo.HEAT
var held_shell_pos = 0

#Due to some VERY annoying internal errors, which might be caused by
#threading problems OR by this script itself, i had to use call_deferred
#in most add_child instances here. While that hasnt aused any problems YET,
#it could potentially do so as something might not be loaded when it needs to be.
#Too bad!

func _ready():
	mesh = owner.get_node("Interior/HullInterior/Dynamic/AmmoBins/" + String(self.name))
	camera = owner.get_node("Players/Loader/Camera/OuterGimbal/InnerGimbal/ClippedCamera")
	loader_camera = owner.get_node("Players/Loader/Camera")
	tween = owner.get_node("Interior/Tween")
	
	#Ammo dict; keys are the ammo positions, values are an enum indicating ammo type
	var j = 0
	for i in mesh.get_children():
		ammo_positions[i] = decode(ammo_code[j])
		positions_array.append(i)
		if ammo_code[j] != "0":
			shell_array.append(i)
		else:
			shell_array.append(null)
		j = j+1

	#Initialize ammo meshes
	for i in ammo_positions:
		if ammo_types[ammo_positions[i]]:
			var ammo_mesh = ammo_types[ammo_positions[i]].instance()
			i.call_deferred("add_child", ammo_mesh)
			ammo_mesh.transform.origin = Vector3.ZERO
			
	active_shell = shell_array[0]
	active_pos = positions_array[find_empty_pos()]

func _process(_delta):
	if not GameState.role == GameState.Role.Loader:
		return
	#find active bin
	if camera.current and loader_camera.aimedObject == self:
		active = true
	else:
		active = false
	
	#if not holding shell, run shell selection animations
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		if active == true and last_active == false and active_shell:
			lift(active_shell)
		
		elif active == false and last_active == true and active_shell:
			lower(active_shell)

	#if holding shell, run shell insertion animations
	else:
		if ((active == true and last_active == false) or (owner.get_node("Players/Loader/Camera").holding_shell == true and last_holding == false and active == true)) and active_pos:
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			active_pos.call_deferred("add_child", shell_scene)

		elif ((active == false and last_active == true) or (owner.get_node("Players/Loader/Camera").holding_shell == false and last_holding == true)) and active_pos:
			if active_pos.get_child(0):
				active_pos.get_child(0).queue_free()
	
	#update last_active (this should be the last line)
	last_active = active
	last_holding = owner.get_node("Players/Loader/Camera").holding_shell

func find_empty_pos():
	for i in ammo_code.length():
		if ammo_code[i] == '0':
			return i
	return null

func find_next_empty_pos():
	for i in range(positions_array.find(active_pos)+1, ammo_code.length()):
		if ammo_code[i] == '0':
			return positions_array[i]
	return null
	
func find_prev_empty_pos():
	for i in range(positions_array.find(active_pos)-1, -1, -1):
		if ammo_code[i] == '0':
			return positions_array[i]
	return null

func decode(i):
	if i == "0":
		return GameState.Ammo.None
	elif i == "1":
		return GameState.Ammo.APC
	elif i == "2":
		return GameState.Ammo.APCR
	elif i == "3":
		return GameState.Ammo.HE
	elif i == "4":
		return GameState.Ammo.HEAT
	elif i == "5":
		return GameState.Ammo.Smoke

func prev_shell():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		var curr_index = shell_array.find(active_shell)
		if (curr_index - 1) >= 0 and shell_array[curr_index - 1] != null:
			lower(active_shell)
			active_shell = shell_array[curr_index - 1]
			lift(active_shell)
	else:
		var prev_pos = find_prev_empty_pos()
		if active and prev_pos and active_pos.get_child(0):
			active_pos.get_child(0).queue_free()
			active_pos = prev_pos
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			active_pos.call_deferred("add_child", shell_scene)

func next_shell():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		var curr_index = shell_array.find(active_shell)
		if ((curr_index + 1) < ammo_code.length()) and shell_array[curr_index + 1] != null:
			lower(active_shell)
			active_shell = shell_array[curr_index + 1]
			lift(active_shell)
	else:
		var next_pos = find_next_empty_pos()
		if active and next_pos and active_pos.get_child(0):
			active_pos.get_child(0).queue_free()
			active_pos = next_pos
			print(positions_array.find(next_pos))
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			active_pos.call_deferred("add_child", shell_scene)

#shell animating funcs
func lift(shell):
	var curr_shell = shell.get_child(0)
	if type == "v":
		tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0.15, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()

func lower(shell):
	var curr_shell = shell.get_child(0)
	if type == "v":
		tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		tween.start()

#important-ass funcs
func remove_shell(shell):
	#references
	owner.get_node("Players/Loader/Camera").held_shell_type = decode(ammo_code[shell_array.find(shell)])
	held_shell_pos = shell_array.find(shell)
	#prepare position code for shell insertion
	active_pos = positions_array[shell_array.find(shell)]
	
	var curr_shell = shell.get_child(0)
	#set shell dict to reflect empty position
	ammo_positions[shell_array.find(shell)] = GameState.Ammo.None
	#set ammo code to reflect empty pos
	ammo_code[shell_array.find(shell)] = '0'
	#set shell array to reflect empty pos
	shell_array[shell_array.find(shell)] = null
	#set holding_shell
	owner.get_node("Players/Loader/Camera").holding_shell = true
	#active shell remains the same, active shell index remains the same

	#animate shell going to camera
	camera = owner.get_node("Players/Loader/Camera/OuterGimbal/InnerGimbal/ClippedCamera") #? A seperate camera or the same one, this was called as a new camera
	shell.remove_child(curr_shell)
	camera.call_deferred("add_child", curr_shell)
	
	tween.interpolate_property(curr_shell, "translation", curr_shell.translation, camera.get_node("RoundPos").translation, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(curr_shell, "rotation_degrees", curr_shell.rotation_degrees, camera.get_node("RoundPos").rotation_degrees, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func add_shell(_pos):
	#TODO: add shell code
	pass

func get_crosshair_tex():
	if owner.get_node("Players/Loader/Camera").holding_shell:
		return smoke_tex
	var type_ = decode(ammo_code[shell_array.find(active_shell)]) #CHECK, is this type scoped correctly, type already exists in this class
	if type_ == GameState.Ammo.HE:
		return he_tex
	elif type_ == GameState.Ammo.HEAT:
		return heat_tex
	elif type_ == GameState.Ammo.APC:
		return apc_tex
	elif type_ == GameState.Ammo.APCR:
		return apcr_tex
	elif type_ == GameState.Ammo.Smoke:
		return smoke_tex

func interact():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		remove_shell(active_shell)
	else:
		add_shell(active_pos)
