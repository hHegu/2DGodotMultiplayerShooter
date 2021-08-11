extends RigidBody2D

export(String, "blue", "red") var team = "blue"

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var player_detector: CollisionShape2D = $PlayerDetector/CollisionShape2D
onready var base_detector: Area2D = $BaseDetector
onready var respawn_timer: Timer = $RespawnTimer
onready var tween: Tween = $Tween
onready var progress_bar: TextureProgress = $TextureProgress

var is_in_base := true


var blue_flag = preload("blue_flag_frames.tres")
var red_flag = preload("red_flag_frames.tres")


# Called when the node enters the scene tree for the first time.
func _ready():
	respawn_timer.start()
	tween.interpolate_property(progress_bar, "value", 100, 0, respawn_timer.wait_time)
	tween.start()

	if team == "red":
		sprite.frames = red_flag
	else:
		sprite.frames = blue_flag
	sprite.playing = true

	add_to_group("{team}_flag".format({"team": team}))
	
	yield(get_tree(), "idle_frame")
	
	set_network_master(1)
	set_physics_process(get_tree().is_network_server())

remotesync func set_pos(data):
	position = data


func _physics_process(delta):
	rpc_unreliable("set_pos", position)


func toggle_player_detector(enabled: bool):
	player_detector.disabled = !enabled


func _on_BaseDetector_area_entered(area):
	respawn_timer.stop()
	tween.stop_all()
	progress_bar.value = 0
	is_in_base = true
	pass # Replace with function body.


func _on_BaseDetector_area_exited(area):
	respawn_timer.start()
	tween.interpolate_property(progress_bar, "value", 100, 0, respawn_timer.wait_time)
	tween.start()
	is_in_base = false
	pass # Replace with function body.


func _on_RespawnTimer_timeout():
	global_position = Game.get_flag_spawn_pos(team).global_position
	pass # Replace with function body.
