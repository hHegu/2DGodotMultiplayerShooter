extends Node

func _ready():
	$ServerBrowser/Menu/LocalIP.text = "Local IP: " + Network.get_IP()
	$ServerBrowser/Menu/Connect/IP.placeholder_text = Network.get_IP()
	$ServerBrowser/Menu/Error.hide()

func _on_Host_pressed():
	if $ServerBrowser/Menu/Username.text == "":
		$ServerBrowser/Menu/Username.text = "Anonymous"
	
	Network.create_server($ServerBrowser/Menu/Username.text)

func _on_Join_pressed():
	if $ServerBrowser/Menu/Connect/IP.text == "":
		$ServerBrowser/Menu/Connect/IP.text = $ServerBrowser/Menu/Connect/IP.placeholder_text
	if $ServerBrowser/Menu/Username.text == "":
		$ServerBrowser/Menu/Username.text = "Anonymous"
	
	Network.join_server($ServerBrowser/Menu/Connect/IP.text, $ServerBrowser/Menu/Username.text)

func _on_text_entered(new_text):
	_on_Join_pressed()
