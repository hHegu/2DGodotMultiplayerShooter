extends Area2D

onready var slot: AnimatedSprite = $FlagSlot
var is_carrying := false

var flag_res = preload("res://objectives/Flag.tscn")

var blue_flag = preload("res://objectives/blue_flag_frames.tres")
var red_flag = preload("res://objectives/red_flag_frames.tres")

func _ready():
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	set_network_master(get_parent().get_parent().get_network_master())
	get_parent().get_parent().connect("on_death", self, "_on_player_death")
	slot.visible = false


func _on_player_death():
	if is_carrying && is_network_master():
		rpc("drop_flag", get_network_master())


remotesync func drop_flag(id):
	is_carrying = false
	var flag = flag_res.instance()
	var my_team = Lobby.players[id].team
	flag.team = "blue" if my_team == "red" else "red"
	flag.global_position = global_position
	flag.is_in_base = false
	get_parent().get_parent().get_parent().add_child(flag)
	slot.visible = false
#
	if get_tree().is_network_server():
		flag.apply_impulse(Vector2.ZERO, Vector2.UP * 50)


remotesync func pick_flag(id):
	var my_team = Lobby.players[get_network_master()].team
	slot.visible = true
	slot.frames = blue_flag if my_team == "red" else red_flag
	slot.play()
	is_carrying = true
	for f in Game.get_flags("red" if my_team == "blue" else "blue"):
		f.queue_free()

remotesync func set_carrying(carrying: bool):
	is_carrying = carrying
	slot.visible = carrying

func _on_FlagHandler_area_entered(area):
	if !get_parent().get_parent().is_dead && is_network_master():
		var flag: RigidBody2D = area.get_parent()
		var my_team = Lobby.players[get_network_master()].team
		if flag.team == my_team:
			if flag.is_in_base && is_carrying:
				Game.rpc("reset_flag", "red" if my_team == "blue" else "blue", randi())
				rpc("set_carrying", false)
				Game.add_score_for_team(my_team)
			return

		rpc("pick_flag", get_network_master())
