extends Control


onready var list: ItemList = $PlayerList
onready var start_button: Button = $Panel/StartButton

func _ready():
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	Lobby.connect("player_joined", self, "_on_player_joined")


func _on_player_joined(players):
	if Network.spawn_for_host:
		start_button.disabled = !get_tree().is_network_server()

	if get_tree().is_network_server():
		rpc("add_players", players)


remotesync func add_players(players):
	list.clear()
	for player in players:
		list.add_item(players[player].username)


func _on_StartButton_pressed():
	Network.load_game()


func _on_QuitButton_pressed():
	Network.my_peer.close_connection()
	Network.back_to_lobby()
	pass # Replace with function body.
