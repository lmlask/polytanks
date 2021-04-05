extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var turret = get_parent().get_node("Visuals/turret")
onready var roleController = get_parent().get_node("RoleController")
onready var crankslow = preload("res://Sfx/crank_slow.wav")
onready var crankfast = preload("res://Sfx/crank_fast.wav")

var traverse_multiplier = 0.4 
var elevation_multiplier = 1 
var traverse_mode = "manual"
var dir : float = 0
var eledir : float = 0
var turn_speed_tgt = 0
var turn_speed = 0
var ele_speed_tgt = 0
var ele_speed = 0
var accel_speed = 1

var was_playing = false
var ele_was_playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):

	#Lerp lever, control mode
	if traverse_mode == "power":
			traverse_multiplier = 2
			accel_speed = 1
	elif traverse_mode == "manual":
			traverse_multiplier = 0.4
			accel_speed = 4
			
	#Turn turret
	turn_speed_tgt = traverse_multiplier * dir * 0.1
	turn_speed = lerp(turn_speed, turn_speed_tgt, (accel_speed*0.1))
	turret.rotate(Vector3(0, 1, 0), turn_speed*delta)
	
	#Elevate
	ele_speed_tgt = eledir * elevation_multiplier * 0.05
	ele_speed = lerp(ele_speed, ele_speed_tgt, 0.1)
	turret.get_node("gun").rotate(Vector3(1, 0, 0), ele_speed*delta)
	
	#Clamp
	turret.get_node("gun").rotation_degrees.x = clamp(turret.get_node("gun").rotation_degrees.x, -17, 10)
	
	
func toggleTraverseMode():
	if traverse_mode == "power":
		traverse_mode = "manual"
	elif traverse_mode == "manual":
		traverse_mode = "power"
	
	
