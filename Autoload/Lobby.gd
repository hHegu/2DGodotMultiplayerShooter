extends Node

# Player info, associate ID to data
var players: Dictionary = {}

signal player_joined
signal player_disconnected_message

var blue_player_count := 0
var red_player_count := 0

func _ready():
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

func add_host():
	var team = "red" if blue_player_count > red_player_count else "blue"
	players[1] = {"username": Network.username, "team": team}
	set_players(players)

func _on_connected_to_server():
	rpc_id(1, "sync_players", {"username": Network.username}, get_tree().get_network_unique_id())


remote func sync_players(player, id):
	if get_tree().is_network_server():
		var team = "red" if blue_player_count > red_player_count else "blue"
		player["team"] = team
		players[id] = player
		rpc("set_players", players)


remotesync func set_players(new_players):
	players = new_players
	emit_signal("player_joined", new_players)
	
	var blues = 0
	var reds = 0
	for player_id in players:
		if players[player_id]["team"] == "red":
			reds += 1
		else:
			blues += 1
	
	blue_player_count = blues
	red_player_count = reds
	


func _on_network_peer_disconnected(id):
	if get_tree().is_network_server():
		emit_signal("player_disconnected_message", players[id].username)
		players.erase(id)
		rpc("set_players", players)
		
	var player = get_tree().get_root().find_node(str(id), true, false)
	if player:
		player.queue_free()

