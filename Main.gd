extends Node

func _ready():
	$CanvasLayer/ServerBrowser/Menu/LocalIP.text = "Local IP: " + Network.get_IP()
	$CanvasLayer/ServerBrowser/Menu/Connect/IP.placeholder_text = Network.get_IP()
	$CanvasLayer/ServerBrowser/Menu/Error.hide()

func _on_Host_pressed():
	if $CanvasLayer/ServerBrowser/Menu/Username.text == "":
		$CanvasLayer/ServerBrowser/Menu/Username.text = "Anonymous"
	
	Network.create_server($CanvasLayer/ServerBrowser/Menu/Username.text)

func _on_Join_pressed():
	if $CanvasLayer/ServerBrowser/Menu/Connect/IP.text == "":
		$CanvasLayer/ServerBrowser/Menu/Connect/IP.text = $CanvasLayer/ServerBrowser/Menu/Connect/IP.placeholder_text
	if $CanvasLayer/ServerBrowser/Menu/Username.text == "":
		$CanvasLayer/ServerBrowser/Menu/Username.text = "Anonymous"
	
	Network.join_server($CanvasLayer/ServerBrowser/Menu/Connect/IP.text, $CanvasLayer/ServerBrowser/Menu/Username.text)

func _on_text_entered(new_text):
	_on_Join_pressed()
