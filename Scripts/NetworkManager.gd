extends Node

var intro:Intro #intro?
remotesync var players = {}

var timer = 0.0 #for debug

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func setup_host():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(8912, 4)
	get_tree().network_peer = peer
	intro.set_status("Your are host")
	intro.disable_options()
	GameState.mode = GameState.Mode.Host
	players[get_tree().get_network_unique_id()] = ""

func join_host():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(intro.get_ip(), 8912)
	get_tree().network_peer = peer
	

func _player_connected(id):
	print("_player_connected-", id)
	if get_tree().is_network_server():
		players[id] = ""
		rset("players", players)
		GameState.rset("DriverID",GameState.DriverID)
		print("send data to ", id)
		GameState.send_game_data()
#	else:
#		get_tree().network_peer.disconnect_peer(id)
	intro.Grid.rpc("disable_role")
	
func _player_disconnected(id):
	print("_player_disconnected-", id)
	players.erase(id)
	GameState.remove_role(id)
	
func _connected_ok():
	print("_connected_ok")
	intro.set_status("Your are connected")
	intro.disable_options()
	GameState.mode = GameState.Mode.Client
	

func _connected_fail():
	print("_connected_fail")
	
func _server_disconnected():
	print("_server_disconnected")
	intro.set_status("You have been disconnected")
	GameState.mode = null
	intro.enable_options()
	get_tree().network_peer = null
	

#func _process(delta):
#	timer += delta
#	if timer > 1.0:
#		timer -= 1
#		print(players)
	
