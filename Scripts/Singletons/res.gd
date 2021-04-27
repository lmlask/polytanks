extends Node

#Nodes
onready var Root = $"/root/gameRoot"
onready var Map:MapMain = Root.get_node("Map")
onready var ManVehicle:ManagerVehicle = Root.get_node("VehicleManager")
onready var FloorFinder:FF = ManVehicle.get_node("FloorFinder")
onready var ManNetwork = Root.get_node("NetworkManager")
onready var GUI = Root.get_node("ViewportContainer/View/GUI")
onready var VTanks = Root.get_node("Vehicles/Tanks") #V for Vehciels ??? maybe N for Node NVTanks
onready var VPlanes = Root.get_node("Vehicles/Planes") #V for Vehciels ??? maybe N for Node NVTanks
onready var VWheeled = Root.get_node("Vehicles/Wheeled") #V for Vehciels ??? maybe N for Node NVTanks
onready var NoiseTex = Map.get_node("NoiseTexture")
onready var Lobby = Root.get_node("Lobby")
onready var TerrainMMI = Map.get_node("TerrainMMI")

var sitesfile = "res://MapData/Sites.dat"
var itemsfile = "res://MapData/Items.dat"
var locsfile = "res://MapData/Locs.dat"
#Scenes
onready var terrain = preload("res://Objects/terrain.tscn")
onready var CamExt = preload("res://Objects/ExternalCamera.tscn")
onready var VTPzIV = preload("res://Tanks/PzIV/PanzerIV.tscn") #Name/sort it better. Put in a dictionary dictionary, Scene Vehicle Tank ?

onready var VWKWagen = preload("res://models/Kubelwagen.tscn")
onready var MHouse = preload("res://models/house.tscn") #Model House
onready var BerHouseS1 = preload("res://models/Berberhouse_small01.tscn")
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

onready var SiteCentre = preload("res://models/SiteCenter.tscn")
onready var DebugUI = preload("res://Scenes/DebugUI.tscn")

onready var Items = {0:[VWKWagen,"K Wagen"],
	1:[BerHouseS1,"Ber House Small 1"],
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

#onready var EnvItems = {0:[Tree01,"Tree 01"], #all wrong
#	1:[Tree02,"Tree 02"],
#	2:[Tree03,"Tree 03"],
#	3:[Rock01,"Rock 01"],
#	4:[Rock02,"Rock 02"],
#	5:[Bush01,"Bush 01"]
#	}
