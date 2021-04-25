extends Area

export var ammo_code : String
export var type : String

var indicator = "hand"
var mesh
var ammo_positions : Dictionary

var apc_tex = preload("res://Textures/Icons/APC.png")
var apcr_tex = preload("res://Textures/Icons/APCR.png")
var he_tex = preload("res://Textures/Icons/HE.png")
var heat_tex = preload("res://Textures/Icons/HEAT.png")
var smoke_tex = preload("res://Textures/Icons/dot.png")

var apc = preload("res://Projectiles/PanzerIV/APC.tscn")
var apcr = preload("res://Projectiles/PanzerIV/APC.tscn")
var he = preload("res://Projectiles/PanzerIV/HE.tscn")
var heat = preload("res://Projectiles/PanzerIV/HEAT.tscn")
var smoke = preload("res://Projectiles/PanzerIV/Smoke.tscn")
var ammo_types = {
	GameState.Ammo.None : null,
	GameState.Ammo.APC : apc,
	GameState.Ammo.APCR : apc,
	GameState.Ammo.HE : he,
	GameState.Ammo.HEAT : heat,
	GameState.Ammo.Smoke : smoke,
}
var active = false
var last_active = false
var active_shell
var camera
var loader_camera
var shell_array : Array
var tween

func _ready():
	mesh = owner.get_node("Interior/HullInterior/Dynamic/AmmoBins/" + String(self.name))
	camera = owner.get_node("Players/Loader/Camera/OuterGimbal/InnerGimbal/ClippedCamera")
	loader_camera = owner.get_node("Players/Loader/Camera")
	tween = owner.get_node("Interior/Tween")
	
	#Ammo dict; keys are the ammo positions, values are an enum indicating ammo type
	var j = 0
	for i in mesh.get_children():
		shell_array.append(i)
		ammo_positions[i] = decode(ammo_code[j])
		j = j+1

	#Initialize ammo meshes
	for i in ammo_positions:
		if ammo_types[ammo_positions[i]]:
			var ammo_mesh = ammo_types[ammo_positions[i]].instance()
			i.add_child(ammo_mesh)
			ammo_mesh.transform.origin = Vector3.ZERO
			
	active_shell = shell_array[0]

func _process(delta):
	if camera.current and loader_camera.aimedObject == self:
		active = true
	else:
		active = false

	if active == true and last_active == false:
		print("lifting")
		lift(active_shell)
	
	if active == false and last_active == true:
		print("lowering")
		lower(active_shell)
	
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
	
func remove_shell(pos):
	ammo_positions[pos] = GameState.Ammo.None
	
func add_shell(pos, type):
	ammo_positions[pos] = type

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

func prev_shell():
	var curr_index = shell_array.find(active_shell)
	if (curr_index - 1) >= 0:
		lower(active_shell)
		active_shell = shell_array[curr_index - 1]
		lift(active_shell)
		print(shell_array.find(active_shell))

func next_shell():
	var curr_index = shell_array.find(active_shell)
	if (curr_index + 1) < ammo_code.length():
		lower(active_shell)
		active_shell = shell_array[curr_index + 1]
		lift(active_shell)
		print(shell_array.find(active_shell))

func get_crosshair_tex():
	var type = decode(ammo_code[shell_array.find(active_shell)])
	print("Type: " + String(type))
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
	pass
