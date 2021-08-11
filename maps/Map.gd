extends YSort


func _ready():
	if get_tree().is_network_server():
#		Game.rpc("add_flags")
		pass
