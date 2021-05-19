extends Node

#Nodes
onready var Root = $"/root/gameRoot"
onready var Map:MapMain = Root.get_node("Map")
onready var ManVehicle:ManagerVehicle = Root.get_node("VehicleManager")
onready var FloorFinder:FF = ManVehicle.get_node("FloorFinder")
onready var ManNetwork = Root.get_node("NetworkManager")
onready var ManMap:MapMain = Root.get_node("Map")
onready var GUI = Root.get_node("ViewportContainer/View/GUI")
onready var VPlayers = Root.get_node("Vehicles/Players") #V for Vehciels ??? maybe N for Node NVTanks
onready var VPlanes = Root.get_node("Vehicles/Planes") #V for Vehciels ??? maybe N for Node NVTanks
onready var VWheeled = Root.get_node("Vehicles/Wheeled") #V for Vehciels ??? maybe N for Node NVTanks
onready var NoiseTex = Map.get_node("NoiseTexture")
onready var Lobby = Root.get_node("Lobby")
onready var TerrainMMI = Map.get_node("TerrainMMI")
onready var Paint:Painter = Map.get_node("Paint")
onready var Editor:Editor = Root.get_node("Editor")

var sitesfile = "res://MapData/Sites.dat"
var itemsfile = "res://MapData/Items.dat"
var locsfile = "res://MapData/Locs.dat"
#Scenes
onready var terrain = preload("res://Objects/terrain.tscn")
onready var CamExt = preload("res://Objects/ExternalCamera.tscn")

onready var VTPzIV = preload("res://Tanks/PzIV/PanzerIV.tscn") #Name/sort it better. Put in a dictionary dictionary, Scene Vehicle Tank ?
onready var VWCamionetta = preload("res://WheeledVehicles/Camionetta/Camionetta.tscn")

onready var VWKWagen = preload("res://models/Kubelwagen.tscn")
onready var MHouse = preload("res://models/house.tscn") #Model House
onready var BerHouseT2 = preload("res://models/BerberHouse02_v2.tscn")
onready var BerHouseT3 = preload("res://models/BerberHouse03_v2.tscn")
onready var BerHouseT4 = preload("res://models/BerberHouse04_v2.tscn")
onready var Grass01 = preload("res://models/grass01.tscn")

onready var Tree01 = preload("res://models/terrain/tree01.tscn") #not intended, to be fixed
onready var Tree02 = preload("res://models/terrain/tree02.tscn") #have a consistent single scene type not
onready var Tree03 = preload("res://models/terrain/tree03.tscn") #these are wrong
onready var Rock01 = preload("res://models/terrain/rock01.tscn")
onready var Rock02 = preload("res://models/terrain/rock02.tscn")
onready var Bush01 = preload("res://models/terrain/bush01.tscn")


onready var Stuka = preload("res://models/Stuka.tscn")
onready var OpalTruck = preload("res://models/opal_truck.tscn")
onready var CamGunTruck = preload("res://models/camion_gun_truck.tscn")

onready var SiteCentre = preload("res://models/SiteCenter.tscn")
onready var DebugUI = preload("res://Scenes/DebugUI.tscn")

onready var Explosion = preload("res://Scenes/Explosion.tscn")

onready var Vehicles = {0:[VTPzIV,"Panzer"],
	1:[VWCamionetta,"Camionetta"]}

onready var Items = {0:[VWKWagen,"K Wagen"],
	2:[BerHouseT2, "Ber House T 2"],
	3:[BerHouseT3, "Ber House T 3"],
	4:[BerHouseT4, "Ber House T 4"],
	5:[Grass01, "Grass 01"],
	6:[MHouse, "WhiteHouse"],
	7:[Tree01, "Tree Tall"],
	8:[Tree02, "Tree Medium"],
	9:[Tree03, "Tree Small"],
	10:[Rock02, "Rock 01"],
	11:[Rock02, "Rock 02"],
	12:[Bush01, "Bush small"],
	}

onready var EnvItems = {0:[Tree01,"Tree 01"], #all wrong
	1:[Tree02,"Tree 02"],
	2:[Tree03,"Tree 03"],
	3:[Rock01,"Rock 01"],
	4:[Rock02,"Rock 02"],
	5:[Bush01,"Bush 01"]
	}

#Tank Ammo
enum TankAmmo {None, APC, APCR, HE, HEAT, Smoke}
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
var TankAmmoTex = {TankAmmo.None:[smoke,smoke_tex],
	TankAmmo.APC:[apc,apc_tex],
	TankAmmo.APCR:[apcr,apcr_tex],
	TankAmmo.HE:[he,he_tex],
	TankAmmo.HEAT:[heat,heat_tex],
	TankAmmo.Smoke:[smoke,smoke_tex]}


var tilefull = Vector3(1024,0,1024)
var tilehalf = tilefull/2
var heightMap = Image.new()
var height_map = {0:["res://Textures/greyalpha-16bit.exr","Test map"],
	1:["res://Textures/flat.exr","Flat map"],
	2:["res://Textures/likethis.exr","Like this map"]}

var max_threads:int = 2
var thread_count:int = 1 #setget set_thred_count
var thread_check:int
var timer:float = 0.0

func _ready():
	max_threads = int(max(2,OS.get_processor_count()*0.75))

func _process(delta): #adjust thread count
	timer += delta
	if timer > 5.0:
		timer -= 5.0
		thread_count = int(clamp(thread_count,1,max_threads))
		if thread_check == 0:
			thread_count -= 1
		thread_check = 0
		get_tree().call_group("terrain","check_thread_count")

	
func pos2grid(pos:Vector3) -> Vector3:
	return (pos/1024).snapped(Vector3(1,1024,1))
func v3xz(v:Vector3)->Vector2:
	return Vector2(v.x,v.z)
	
func load_image(map):
	if not map == -1:
		heightMap = load(height_map[map][0]).get_data()
		heightMap.lock()
