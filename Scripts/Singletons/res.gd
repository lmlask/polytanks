extends Node

#Nodes
onready var Root = $"/root/gameRoot"
onready var Map:MapMain = Root.get_node("Map")
onready var ManVehicle:ManagerVehicle = Root.get_node("VehicleManager")
onready var ManNetwork = Root.get_node("NetworkManager")
onready var GUI = Root.get_node("ViewportContainer/View/GUI")
onready var VTanks = Root.get_node("Vehicles/Tanks") #V for Vehciels ??? maybe N for Node NVTanks

#Scenes
onready var CamExt = preload("res://Objects/ExternalCamera.tscn")
onready var VTPzIV = preload("res://Tanks/PzIV/PanzerIV.tscn") #Name/sort it better. Put in a dictionary dictionary, Scene Vehicle Tank ?
onready var DebugUI = preload("res://Scenes/DebugUI.tscn")