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
var just_active = false
var just_inactive = false

var active_pos

func _ready():
	#Initialize spatials array
	positions_array = mesh.get_children()
	#Initialize ammo meshes
	for i in range(0, positions_array.size()):
		if ammo_types[decode(ammo_code[i])]:
#			var ammo_mesh = ammo_types[decode(ammo_code[i])].instance()
			var ammo_mesh = R.TankAmmoTex[R.TankAmmo.values()[int(ammo_code[i])]][0].instance() #HERE
			positions_array[i].call_deferred("add_child", ammo_mesh)
			ammo_mesh.transform.origin = Vector3.ZERO
			
	active_pos = null

func _process(_delta):
	
	if not GameState.role == GameState.Role.Loader:
		return
		
	#active
	if camera.current and loader_camera.aimedObject == self:
		active = true
	else:
		active = false
		
	#holding shell
	holding = owner.get_node("Players/Loader/Camera").holding_shell
	
	#set frame variables
	if active == true and last_active == false:
		just_active = true
		
	if active == false and last_active == true:
		just_inactive = true
	
	#Bin you just looked to, while holding nothing
	if just_active and !holding:
		if activate_first_filled_pos():
			lift(active_pos)
	
	#Bin you just unlooked to, while holding nothing
	elif just_inactive and !holding:
		lower(active_pos)
	
	#Bin you just looked to, holding a shell
	if just_active and holding:
		if activate_first_empty_pos():
			show_ghost(active_pos)
	
	#Bin you just unlooked to, holding a shell
	#BUG: hides shell when unlooking from any filled bin
	elif just_inactive and holding and bin_not_filled():
		hide_ghost(active_pos)
	
	#IMPORTANT:
	#Bin you just took from: can be in the remove_shell function
	#Bin you just added to: can be in the add_shell function 
	
	#reset frame variables
	last_active = active
	last_holding = holding
	just_active = false
	just_inactive = false

#ammo code
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

#shell navigation
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
			show_ghost(active_pos)

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
			show_ghost(active_pos)

func activate_first_filled_pos():
	var curr_index = 0
	while curr_index + 1 < ammo_code.length() and ammo_code[curr_index] == '0':
		curr_index = curr_index + 1
	if ammo_code[curr_index] != '0':
		active_pos = positions_array[curr_index]
		return true
	else:
		#all empty.
		return false
		
func activate_first_empty_pos():
	var curr_index = 0
	while curr_index + 1 < ammo_code.length() and ammo_code[curr_index] != '0':
		curr_index = curr_index + 1
	if ammo_code[curr_index] == '0':
		active_pos = positions_array[curr_index]
		return true
	else:
		#all filled.
		return false

func bin_not_filled():
	var curr_index = 0
	while curr_index + 1 < ammo_code.length() and ammo_code[curr_index] != '0':
		curr_index = curr_index + 1
	if ammo_code[curr_index] == '0':
		return true
	else:
		#all filled.
		return false

#shell animating and visual funcs
func lift(pos):
	var curr_shell = pos.get_child(0)
	tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0.15, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func lower(pos):
	var curr_shell = pos.get_child(0)
	tween.interpolate_property(curr_shell, "translation:y", curr_shell.translation.y, 0, 0.4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	
func show_ghost(pos):
	var shell_scene = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
	shell_scene.material_override = transp_mat
	pos.add_child(shell_scene)
	
func hide_ghost(pos):
	pos.remove_child(pos.get_child(0))

#removing and adding shells
func remove_shell(pos):
	#script vars and refs
	owner.get_node("Players/Loader/Camera").held_shell_type = decode(ammo_code[positions_array.find(pos)])
	var curr_shell = pos.get_child(0)
	owner.get_node("Players/Loader/Camera").holding_shell = true
	#set ammo code to reflect empty pos
	ammo_code[positions_array.find(pos)] = '0'
	#animate shell going to camera
	pos.remove_child(curr_shell)
	camera.add_child(curr_shell)
	
	tween.interpolate_property(curr_shell, "translation", curr_shell.translation, camera.get_node("RoundPos").translation, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(curr_shell, "rotation_degrees", curr_shell.rotation_degrees, camera.get_node("RoundPos").rotation_degrees, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	show_ghost(pos)

func add_shell(pos):
	#script vars and refs
	var shell_mesh = ammo_types[owner.get_node("Players/Loader/Camera").held_shell_type].instance()
	
	hide_ghost(pos)
	camera.get_child(3).queue_free()
	
	pos.add_child(shell_mesh)
	shell_mesh.translation.y = 0.15
	
	#set ammo code to reflect filled pos
	ammo_code[positions_array.find(pos)] = encode(owner.get_node("Players/Loader/Camera").held_shell_type)
	
	owner.get_node("Players/Loader/Camera").held_shell_type = GameState.Ammo.None
	owner.get_node("Players/Loader/Camera").holding_shell = false

func interact():
	if owner.get_node("Players/Loader/Camera").holding_shell == false:
		remove_shell(active_pos)
	else:
		if bin_not_filled():
			add_shell(active_pos)

func get_crosshair_tex():
	if owner.get_node("Players/Loader/Camera").holding_shell:
		return smoke_tex
	
	return R.TankAmmoTex[ R.TankAmmo.values() [int(ammo_code[positions_array.find(active_pos)])] ] [1] #HERE
	
#	var ammotype = decode(ammo_code[positions_array.find(active_pos)]) #CHECK, is this type scoped correctly, type already exists in this class
#	if ammotype == GameState.Ammo.HE:
#		return he_tex
#	elif ammotype == GameState.Ammo.HEAT:
#		return heat_tex
#	elif ammotype == GameState.Ammo.APC:
#		return apc_tex
#	elif ammotype == GameState.Ammo.APCR:
#		return apcr_tex
#	elif ammotype == GameState.Ammo.Smoke:
#		return smoke_tex
