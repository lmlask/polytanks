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
var active_shell

var loader_camera
var tween
var held_shell_type = GameState.Ammo.APC
var held_shell_pos = 0
var active_shell_index


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
			i.add_child(ammo_mesh)
			ammo_mesh.transform.origin = Vector3.ZERO
			
	active_shell = shell_array[0]
	active_shell_index = 0

func _process(delta):
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
	else:
		pass
#		if active == true and last_active == false and active_shell:
#			positions_array[active_shell_index].add_child(ammo_types[held_shell_type].instance())
#
#		elif active == false and last_active == true and active_shell:
#			positions_array[active_shell_index].get_child(0).queue_free()
		
	
	#update last_active (this should be the last line)
	last_active = active


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
	var curr_index = shell_array.find(active_shell)
	if (curr_index - 1) >= 0 and shell_array[curr_index - 1] != null:
		lower(active_shell)
		active_shell = shell_array[curr_index - 1]
		active_shell_index = active_shell_index - 1
		if owner.get_node("Players/Loader/Camera").holding_shell == false:
			lift(active_shell)
		return true
	else:
		return false

func next_shell():
	var curr_index = shell_array.find(active_shell)
	if ((curr_index + 1) < ammo_code.length()) and shell_array[curr_index + 1] != null:
		lower(active_shell)
		active_shell = shell_array[curr_index + 1]
		active_shell_index = active_shell_index + 1
		if owner.get_node("Players/Loader/Camera").holding_shell == false:
			lift(active_shell)
		return true
	else:
		return false

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

func remove_shell(shell):
	#references
	held_shell_type = decode(ammo_code[shell_array.find(shell)])
	held_shell_pos = shell_array.find(shell)
	
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

	#animate shell leaving bin
	tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0.2, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	#animate shell going to camera
	var camera = owner.get_node("Players/Loader/Camera/OuterGimbal/InnerGimbal/ClippedCamera")
	shell.remove_child(curr_shell)
	camera.add_child(curr_shell)

	
	tween.interpolate_property(curr_shell, "translation", curr_shell.translation, camera.get_node("RoundPos").translation, 2, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(curr_shell, "rotation_degrees", curr_shell.rotation_degrees, camera.get_node("RoundPos").rotation_degrees, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func add_shell(pos, type):
	ammo_positions[pos] = type

func get_crosshair_tex():
	if owner.get_node("Players/Loader/Camera").holding_shell:
		return smoke_tex
	var type = decode(ammo_code[shell_array.find(active_shell)])
	if type == GameState.Ammo.HE:
		return he_tex
	elif type == GameState.Ammo.HEAT:
		return heat_tex
	elif type == GameState.Ammo.APC:
		return apc_tex
	elif type == GameState.Ammo.APCR:
		return apcr_tex
	elif type == GameState.Ammo.Smoke:
		return smoke_tex

func interact():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		remove_shell(active_shell)
