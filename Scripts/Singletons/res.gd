extends Node

#Nodes
onready var Root = $"/root/gameRoot"
onready var Map:MapMain = Root.get_node("Map")
onready var ManVehicle:ManagerVehicle = Root.get_node("VehicleManager")
onready var FloorFinder:FF = ManVehicle.get_node("FloorFinder")
onready var ManNetwork = Root.get_node("NetworkManager")
onready var GUI = Root.get_node("ViewportContainer/View/GUI")
onready var VTanks = Root.get_node("Vehicles/Tanks") #V for Vehciels ??? maybe N for Node NVTanks
onready var NoiseTex = Map.get_node("NoiseTexture")

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

onready var SiteCentre = preload("res://models/SiteCenter.tscn")
onready var DebugUI = preload("res://Scenes/DebugUI.tscn")

onready var Items = {0:[VWKWagen,"K-Wagen"],
	1:[BerHouseS1,"Ber House Small 1"],
	2:[BerHouseT2, "Ber House T 2"],
	3:[BerHouseT3, "Ber House T 3"],
	4:[BerHouseT4, "Ber House T 4"],
	5:[Grass01, "Grass 01"]
	}
