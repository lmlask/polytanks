extends Control

var vehicle# = $"../VehicleManager".vehicle

func _ready():
	disable()
	vehicle = get_parent().VehicleManager.vehicle #clean up

func disable():
	set_process(false)
	for i in get_children():
		i.set_process(false) #bad code
	pass # Replace with function body.

func enable():
	set_process(true)
	for i in get_children():
		i.set_process(true) #bad code
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
