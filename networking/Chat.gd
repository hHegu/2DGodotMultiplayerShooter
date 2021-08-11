extends Control

var max_messages = 10

var can_use = true


func _ready():
	$Message.hide()
	
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	
	if get_tree().is_network_server():
		rpc("send_message_online", "-- Server is running --", Color(1, 1, 0))
		Lobby.connect("player_disconnected_message", self, "_on_player_disconnected")
	else:
		rpc("send_message_online", "-- " + Network.username + " has joined the game --", Color(1, 1, 0))

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		if can_use:
			can_use = false
			
			if $Message.visible:
				if $Message/TypedMessage.text != "":
					rpc("send_message_online", Network.username + ": " + $Message/TypedMessage.text, Color(1, 1, 1))
				$Message.visible = false
				$Message/TypedMessage.clear()
				$MessagesFadeOutTimer.start()
			else:
				$MessagesFadeOutTimer.stop()
				$Message.visible = true
				$Message/TypedMessage.grab_focus()
				$ChatBox.show()
	else:
		can_use = true

remotesync func send_message_online(message, color):
	$ChatBox.show()
	
	if not $Message.visible:
		$MessagesFadeOutTimer.start()
	
	var display_message = Label.new()
	display_message.text = message
	display_message.modulate = color
	$ChatBox.add_child(display_message)
	
	# Limit the messages that are displayed
	if $ChatBox.get_child_count() > max_messages:
		$ChatBox.get_child(0).queue_free()

func _on_MessagesFadeOutTimer_timeout():
	$ChatBox.hide()

func _on_player_disconnected(username):
	if is_network_master():
		rpc("send_message_online", "{name} disconnected".format({"name": username}), Color.red)
	pass
	

