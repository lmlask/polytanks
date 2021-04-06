extends Node

# global vars
var mouseHidden : bool = false
var debugMode : bool = false
var DebugUI = load("res://Scenes/DebugUI.tscn").instance()
onready var gameRoot = get_node("/root/gameRoot")
enum Mode {Host, Client}
enum Role {Driver, Gunner}
var mode
var role:int
var tank:int
var InGame = false
puppet var DriverID = {}

func _ready() -> void:
	pass
#	gameRoot.add_child(DebugUI) #make optional
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

remotesync func set_driver_id(tank, id):
#	print("set driver",tank,id)
	DriverID[tank] = id
#	print(DriverID)

func setup_debug():
	gameRoot.add_child(DebugUI) #make optional

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if mouseHidden == true:
			show_mouse()
		else:
			hide_mouse()
	if event.is_action_pressed("debug_key"):
		if debugMode == true:
			debugMode = false
		else:
			debugMode = true

func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	OS.window_fullscreen = true
	mouseHidden = true

func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	OS.window_fullscreen = false
	mouseHidden = false

#func _process(delta):
#	print(DriverID)
