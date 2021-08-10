extends Node

# Player info, associate ID to data
var players = {}

signal player_joined

func _ready():
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

func add_host():
	players[1] = {"username": Network.username}
	set_players(players)

func _on_connected_to_server():
	rpc_id(1, "sync_players", {"username": Network.username}, get_tree().get_network_unique_id())


remote func sync_players(player, id):
	if get_tree().is_network_server():
		players[id] = player
		rpc("set_players", players)


remotesync func set_players(new_players):
	players = new_players
	emit_signal("player_joined", new_players)


func _on_network_peer_disconnected(id):
	if get_tree().is_network_server():
		players.erase(id)
		rpc("set_players", players)
