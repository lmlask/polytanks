extends "res://Scripts/FPCamera.gd"

onready var he = preload("res://Textures/Icons/HE.png")
onready var apc = preload("res://Textures/Icons/APC.png")
onready var heat = preload("res://Textures/Icons/HEAT.png")
onready var apcr = preload("res://Textures/Icons/APCR.png")
onready var smoke = preload("res://Textures/Icons/dot.png")

var holding_shell = false
var held_shell_type

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_parent().get_parent().get_parent().get_node("Interior/TurretInterior/LoaderClickables").get_children():
		interact_areas.append(i)
	for i in get_parent().get_parent().get_parent().get_node("Interior/HullInterior/LoaderClickables").get_children():
		interact_areas.append(i)
