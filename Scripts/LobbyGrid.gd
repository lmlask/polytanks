extends GridContainer

var selected = [null,null]

func _ready():
	for i in R.Vehicles:
		$Tank1/Vehicle.add_item(R.Vehicles[i][1],i)
	for i in range(1,3):
		var x = $Tank1.duplicate()
		add_child(x)
		x.get_node("Label").text = str("Tank %s" % (i+1))
		x.name = str("Tank%s" % (i+1))
		x.Tank = i
		x.owner = owner

func set_all_roles(state):
	for i in get_children():
		for j in i.get_children():
			if j is Button and not j is OptionButton:
				j.disabled = state
	
remotesync func disable_role(j=false):
	if j:
		set_all_roles(false)
	for i in get_children():
#		i.rpc("disable_role",selected[0],selected[1])
		i.rpc("disable_role",GameState.tank,GameState.role)
