extends RigidBody2D

export(String, "blue", "red") var team = "blue"

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var player_detector: CollisionShape2D = $PlayerDetector/CollisionShape2D
onready var base_detector: Area2D = $BaseDetector
onready var respawn_timer: Timer = $RespawnTimer


var is_in_base := true


var blue_flag = preload("blue_flag_frames.tres")
var red_flag = preload("red_flag_frames.tres")


# Called when the node enters the scene tree for the first time.
func _ready():
	respawn_timer.start()
	if team == "red":
		sprite.frames = red_flag
	else:
		sprite.frames = blue_flag
	sprite.playing = true

	add_to_group("{team}_flag".format({"team": team}))

	set_network_master(1)
	set_physics_process(is_network_master())

remotesync func set_pos(data):
	position = data


func _physics_process(delta):
	rpc_unreliable("set_pos", position)


func toggle_player_detector(enabled: bool):
	player_detector.disabled = !enabled


func _on_BaseDetector_area_entered(area):
	respawn_timer.stop()
	is_in_base = true
	pass # Replace with function body.


func _on_BaseDetector_area_exited(area):
	respawn_timer.start()
	is_in_base = false
	pass # Replace with function body.


func _on_RespawnTimer_timeout():
	global_position = Game.get_flag_spawn_pos(team).global_position
	pass # Replace with function body.