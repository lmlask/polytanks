extends VBoxContainer

var Tank = 0


	

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
		$Vehicle.disabled = true
		match role:
			GameState.Role.Driver:
				$Driver.disabled = true
				$Vehicle.disabled = false
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


func _on_Vehicle_item_selected(index):
	owner.Vehicle = R.Vehicles[index][0]
