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

#Scenes
onready var CamExt = preload("res://Objects/ExternalCamera.tscn")
onready var VTPzIV = preload("res://Tanks/PzIV/PanzerIV.tscn") #Name/sort it better. Put in a dictionary dictionary, Scene Vehicle Tank ?
onready var VWKWagen = preload("res://models/Kubelwagen.tscn")
onready var MHouse = preload("res://models/house.tscn") #Model House
onready var BerHouseS1 = preload("res://models/Berberhouse_small01.tscn")
onready var BerHouseT2 = preload("res://models/BerberHouse02_v2.tscn")
onready var BerHouseT3 = preload("res://models/BerberHouse03_v2.tscn")
onready var BerHouseT4 = preload("res://models/BerberHouse04_temp.tscn")
onready var DebugUI = preload("res://Scenes/DebugUI.tscn")
