extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ext_camera : bool

var role

var taken = {
	"driver" : false,
	"radioman" : false,
	"gunner" : false,
	"commander" : false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if owner.active:
		role = "driver"
		changeRole(role)
	

func changeRole(newrole):
	taken[role] = false
	if not owner.auto:
		role = newrole
	taken[role] = true


func _process(_delta):
	if Input.is_action_just_pressed("rolechange_driver"):
		changeRole("driver")
	elif Input.is_action_just_pressed("rolechange_radioman"):
		changeRole("radioman")
	elif Input.is_action_just_pressed("rolechange_gunner"):
		changeRole("gunner")
	elif Input.is_action_just_pressed("rolechange_commander"):
		changeRole("commander")
		
