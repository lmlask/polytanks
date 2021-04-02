extends Node

var intro:Intro #intro?


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

func join_host():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("127.0.0.1", 8912)
	get_tree().network_peer = peer
	

func _player_connected(id):
	print("_player_connected-", id)
	intro.set_status("Player %s connected" % id)
	
func _player_disconnected(id):
	print("_player_disconnected-", id)
	
func _connected_ok():
	print("_connected_ok")
	intro.set_status("Your are connected")
	intro.disable_options()
	GameState.mode = GameState.Mode.Client
	
func _connected_fail():
	print("_connected_fail")
	
func _server_disconnected():
	print("_server_disconnected")
	
