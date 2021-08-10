extends Node

var red_score = 0
var blue_score = 0

signal score_changed

var flag_res = preload("res://objectives/Flag.tscn")

remotesync func set_score(blue: int, red: int):
	red_score = red
	blue_score = blue
	
	emit_signal("score_changed")


func add_score_for_team(team: String):
	self["{team}_score".format({"team": team})] += 1
	rpc("set_score", blue_score, red_score)


remotesync func add_flags():
	for team in ["blue", "red"]:
		var flag_instance = flag_res.instance()
		flag_instance.team = team
		flag_instance.global_position = get_flag_spawn_pos(team).global_position
		get_tree().get_root().find_node("Map", true, false).add_child(flag_instance)


func get_flag_spawn_pos(team: String):
	return get_tree().get_root().find_node("{team}_flag_spawn".format({"team": team}), true, false)

func get_flags(team: String):
	return get_tree().get_nodes_in_group("{team}_flag".format({"team": team}))

remotesync func reset_flag(team: String):
	for flag in get_tree().get_nodes_in_group("{team}_flag".format({"team": team})):
		flag.queue_free()
	
	var flag_instance = flag_res.instance()
	flag_instance.team = team
	flag_instance.global_position = get_flag_spawn_pos(team).global_position
	get_tree().get_root().find_node("Map", true, false).add_child(flag_instance)
