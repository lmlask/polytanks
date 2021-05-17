extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

master func hit(type, angle, shape): 
	var thickness = get_child(shape).shape.extents.z
	print("hit %s/%s by:%s angle:%s thickness:%s" % [self.name, shape, GameState.Ammo.keys()[type], angle, thickness] ) 
	
