extends Node

# If true, the server can also play
var spawn_for_host := true

var username = ""

var main = "res://Main.tscn"
var map = "res://maps/Map.tscn"
var player = "res://player/Player.tscn"
var lobby = "res://Lobby.tscn"
var game_ui = "res://UI/GameUI.tscn"

var spawn = null

var my_peer: NetworkedMultiplayerENet

var network_tick: Timer

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	network_tick = Timer.new()
	network_tick.wait_time = 0.03
	network_tick.autostart = true
	add_child(network_tick)


func create_server(username_chosen):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(7777, 32)
	get_tree().set_network_peer(peer)
	my_peer = peer
	
	if !spawn_for_host:
		AudioServer.set_bus_mute(0, true) # The server mutes the game
	username = username_chosen + " (host)"

	load_lobby()
	if spawn_for_host:
		Lobby.add_host()


func join_server(to_ip, username_chosen):
	username = username_chosen
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(to_ip, 7777)
	get_tree().set_network_peer(peer)
	my_peer = peer


func load_lobby():
	get_tree().get_root().find_node("ServerBrowser", true, false).visible = false
	get_tree().get_root().find_node("PreGameLobby", true, false).visible = true


func back_to_lobby():
	get_tree().get_root().find_node("ServerBrowser", true, false).visible = true
	get_tree().get_root().find_node("PreGameLobby", true, false).visible = false


func load_game():
	rpc("trigger_loads")
	Game.add_flags()


remotesync func trigger_loads():
	var map_resource = load(map)
	var map_instance = map_resource.instance()
	get_tree().get_root().find_node("World", true, false).add_child(map_instance)
	get_tree().get_root().find_node("PreGameLobby", true, false).visible = false
	
	var ui_instance = load(game_ui).instance()
	get_tree().get_root().find_node("Main", true, false).add_child(ui_instance)
	
	yield(get_tree().create_timer(0.01), "timeout")
	
	if !get_tree().is_network_server() or spawn_for_host:
		var id = get_tree().get_network_unique_id()
		var team = Lobby.players[id]["team"]
		spawn = get_spawn_location(team)
		rpc("remote_load_game", get_tree().get_network_unique_id(), spawn.global_transform)


remotesync func remote_load_game(id: int, spawn_pos: Transform2D):
	
	yield(get_tree().create_timer(0.01), "timeout")

	spawn_player(id, spawn_pos)


func get_spawn_location(team: String):
	var spawner = get_tree().get_root().find_node("{team}_spawners".format({"team": team}), true, false)
	randomize()
	return spawner.get_child( randi() % spawner.get_child_count() )


func spawn_player(id, position):
	var player_instance = load(player).instance()
	player_instance.name = str(id)
	get_node("/root/Main/World").get_child(0).add_child(player_instance)
	player_instance.global_transform = position
	
	player_instance.set_network_master(id)


func get_IP():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			return ip


# Spawn the other players that connected exepted from the server:
func _on_network_peer_connected(id):
	pass
#	if id != 1 and !spawn_for_host: # If this is not the server spawn the player
#		spawn_player(id)


func _on_network_peer_disconnected(id):
#	if id != 1 or spawn_for_host:
#		get_tree().get_root().find_node(str(id), true, false).queue_free()
	pass


func _on_connected_to_server():
	load_lobby()

func _on_server_disconnected():
	get_tree().change_scene(main)
	get_tree().set_network_peer(null)
