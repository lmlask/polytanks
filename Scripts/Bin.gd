extends Area

#Ammo code, always in sync, can be used to change initial shells in bin
#0 = empty; 1 = APC; 2 = APCR; 3 = HE; 4 = HEAT; 5 = Smoke
export var ammo_code : String

#Required for interactable object to work
var indicator = "hand"

onready var mesh = owner.get_node("Interior/HullInterior/Dynamic/AmmoBins/" + String(self.name))
onready var camera = owner.get_node("Players/Loader/Camera/OuterGimbal/InnerGimbal/ClippedCamera")
onready var loader_camera = owner.get_node("Players/Loader/Camera")
onready var tween = owner.get_node("Interior/Tween")

#Crosshair textures
var apc_tex = preload("res://Textures/Icons/APC.png")
var apcr_tex = preload("res://Textures/Icons/APCR.png")
var he_tex = preload("res://Textures/Icons/HE.png")
var heat_tex = preload("res://Textures/Icons/HEAT.png")
var smoke_tex = preload("res://Textures/Icons/dot.png")

#Shell textures
var apc = preload("res://Projectiles/PanzerIV/APC.tscn")
var apcr = preload("res://Projectiles/PanzerIV/APCR.tscn")
var he = preload("res://Projectiles/PanzerIV/HE.tscn")
var heat = preload("res://Projectiles/PanzerIV/HEAT.tscn")
var smoke = preload("res://Projectiles/PanzerIV/Smoke.tscn")

var transp_mat = preload("res://Materials/transp_projectile.tres")

#Data
#Ammo types, type enum : scene
var ammo_types = {
	GameState.Ammo.None : null,
	GameState.Ammo.APC : apc,
	GameState.Ammo.APCR : apcr,
	GameState.Ammo.HE : he,
	GameState.Ammo.HEAT : heat,
	GameState.Ammo.Smoke : smoke,
}
#Spatials in bin
var positions_array : Array

#Bools
var active = false
var holding = false
var last_active = false
var last_holding = false

var active_pos

#I had to use call_deferred in most add_child instances here. 
#While that hasnt aused any problems, it could potentially do
#so as something might not be loaded when it needs to be.
#Too bad!

func _ready():
	#Initialize spatials array
	positions_array = mesh.get_children()
	#Initialize ammo meshes
	for i in range(0, positions_array.size()):
		if ammo_types[decode(ammo_code[i])]:
			var ammo_mesh = ammo_types[decode(ammo_code[i])].instance()
			positions_array[i].call_deferred("add_child", ammo_mesh)
			ammo_mesh.transform.origin = Vector3.ZERO
	active_pos = positions_array[0]

func _process(_delta):
	
	if not GameState.role == GameState.Role.Loader:
		return
	#find active bin
	if camera.current and loader_camera.aimedObject == self:
		active = true
	else:
		active = false
		
	holding = owner.get_node("Players/Loader/Camera").holding_shell
	
	#if not holding shell, run shell selection animations
	if holding == false:
		if active == true and last_active == false and active_pos:
			lift(active_pos)
		
		elif active == false and last_active == true and active_pos:
			lower(active_pos)

	#if holding shell, run shell insertion animations
	else:
		if ((active == true and last_active == false) or (holding == true and last_holding == false and active == true)) and active_pos:
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			if active_pos:
				active_pos.call_deferred("add_child", shell_scene)
			else:
				active_pos = positions_array[find_empty_pos()]
				print(active_pos)
				active_pos.call_deferred("add_child", shell_scene)

		elif ((active == false and last_active == true) or (holding == false and last_holding == true)) and active_pos:
			if active_pos.get_child(0):
				active_pos.get_child(0).queue_free()
	
	#update last_ variables (this should be the last line)
	last_active = active
	last_holding = holding

func find_empty_pos():
	for i in ammo_code.length():
		if ammo_code[i] == '0':
			return i
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

func encode(i):
	if i == GameState.Ammo.None:
		return "0"
	elif i == GameState.Ammo.APC:
		return "1"
	elif i == GameState.Ammo.APCR:
		return "2"
	elif i == GameState.Ammo.HE:
		return "3"
	elif i == GameState.Ammo.HEAT:
		return "4"
	elif i == GameState.Ammo.Smoke:
		return "5"

func prev_shell():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		var curr_index = positions_array.find(active_pos)
		while (curr_index > 0 and ammo_code[curr_index - 1] == '0'):
			curr_index = curr_index - 1
		if (curr_index > 0 and ammo_code[curr_index - 1] != '0'):
			lower(active_pos)
			active_pos = positions_array[curr_index - 1]
			lift(active_pos)
	else:
		var curr_index = positions_array.find(active_pos)
		while (curr_index > 0 and ammo_code[curr_index - 1] != '0'):
			curr_index = curr_index - 1
		if active and curr_index > 0 and ammo_code[curr_index - 1] == '0':
			active_pos.get_child(0).queue_free()
			active_pos = positions_array[curr_index - 1]
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			active_pos.call_deferred("add_child", shell_scene)

func next_shell():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		var curr_index = positions_array.find(active_pos)
		while curr_index + 1 < ammo_code.length() and ammo_code[curr_index + 1] == '0':
			curr_index = curr_index + 1
		if active and curr_index + 1 < ammo_code.length() and ammo_code[curr_index + 1] != '0':
			lower(active_pos)
			active_pos = positions_array[curr_index + 1]
			lift(active_pos)
	else:
		var curr_index = positions_array.find(active_pos)
		while (curr_index + 1 < ammo_code.length() and ammo_code[curr_index + 1] != '0'):
			curr_index = curr_index + 1
		if active and curr_index + 1 < ammo_code.length() and ammo_code[curr_index + 1] == '0':
			active_pos.get_child(0).queue_free()
			active_pos = positions_array[curr_index + 1]
			var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
			shell_scene.material_override = transp_mat
			active_pos.call_deferred("add_child", shell_scene)

#shell animating funcs
func lift(pos):
	var curr_shell = pos.get_child(0)
	tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0.15, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func lower(pos):
	var curr_shell = pos.get_child(0)
	tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

#important-ass funcs
func remove_shell(pos):
	#references
	owner.get_node("Players/Loader/Camera").held_shell_type = decode(ammo_code[positions_array.find(pos)])
	var curr_shell = pos.get_child(0)

	#set ammo code to reflect empty pos
	ammo_code[positions_array.find(pos)] = '0'

	#set holding_shell
	owner.get_node("Players/Loader/Camera").holding_shell = true

	#animate shell going to camera
	pos.remove_child(curr_shell)
	camera.call_deferred("add_child", curr_shell)
	
	tween.interpolate_property(curr_shell, "translation", curr_shell.translation, camera.get_node("RoundPos").translation, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(curr_shell, "rotation_degrees", curr_shell.rotation_degrees, camera.get_node("RoundPos").rotation_degrees, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func add_shell(pos):
	pass

func interact():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		remove_shell(active_pos)
	else:
		add_shell(active_pos)

func get_crosshair_tex():
	if owner.get_node("Players/Loader/Camera").holding_shell:
		return smoke_tex
	var ammotype = decode(ammo_code[positions_array.find(active_pos)]) #CHECK, is this type scoped correctly, type already exists in this class
	if ammotype == GameState.Ammo.HE:
		return he_tex
	elif ammotype == GameState.Ammo.HEAT:
		return heat_tex
	elif ammotype == GameState.Ammo.APC:
		return apc_tex
	elif ammotype == GameState.Ammo.APCR:
		return apcr_tex
	elif ammotype == GameState.Ammo.Smoke:
		return smoke_tex
