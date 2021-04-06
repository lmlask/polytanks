extends GridContainer

var selected = [null,null]

func _ready():
	for i in range(1,4):
		var x = $Tank1.duplicate()
		add_child(x)
		x.get_node("Label").text = str("Tank %s" % (i+1))
		x.name = str("Tank%s" % (i+1))
		x.Tank = i

func set_all_roles(state):
	for i in get_children():
		for j in i.get_children():
			if j is Button:
				j.disabled = state
	
remotesync func disable_role():
	for i in get_children():
		i.rpc("disable_role",selected[0],selected[1])
