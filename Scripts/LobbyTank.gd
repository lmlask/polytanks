extends VBoxContainer

var Tank = 0

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Driver_pressed():
	rpc("select", Tank, GameState.Role.Driver)

func _on_Gunner_pressed():
	rpc("select", Tank, GameState.Role.Gunner)

remotesync func select(tank, role):
	get_parent().set_all_roles(false)
	if get_tree().get_network_unique_id() == get_tree().get_rpc_sender_id():
#		get_parent().selected = [tank,role]
		GameState.tank = tank
		GameState.role = role
	get_parent().rpc("disable_role")
	
remotesync func disable_role(tank,role):
	if Tank == tank:
		match role:
			GameState.Role.Driver:
				$Driver.disabled = true
			GameState.Role.Gunner:
				$Gunner.disabled = true
			GameState.Role.Commander:
				$Commander.disabled = true
			GameState.Role.Loader:
				$Loader.disabled = true
			GameState.Role.Radioman:
				$Radioman.disabled = true


func _on_Commander_pressed():
	rpc("select", Tank, GameState.Role.Commander)


func _on_Loader_pressed():
	rpc("select", Tank, GameState.Role.Loader)


func _on_Radioman_pressed():
	rpc("select", Tank, GameState.Role.Radioman)
