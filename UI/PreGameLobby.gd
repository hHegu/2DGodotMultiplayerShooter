extends Control


onready var list: ItemList = $PlayerList
onready var start_button: Button = $Panel/StartButton


var red_icon: Texture = preload("res://assets/team_icons/team_icon_red.png")
var blue_icon: Texture = preload("res://assets/team_icons/team_icon_blue.png")


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
		var team = players[player].team
		var player_text = "[{team}] {player}".format({"player": players[player].username, "team": team})
		list.add_item(player_text, red_icon if team == "red" else blue_icon)
	list.sort_items_by_text()


func _on_StartButton_pressed():
	Network.load_game()


func _on_QuitButton_pressed():
	Network.my_peer.close_connection()
	Network.back_to_lobby()
	pass # Replace with function body.


func _on_ChangeTeamButton_pressed():
	var my_id = get_tree().get_network_unique_id()
	var my_team = Lobby.players[my_id].team
	Lobby.players[my_id].team = "red" if my_team == "blue" else "blue"
	Lobby.rpc("set_players", Lobby.players)
