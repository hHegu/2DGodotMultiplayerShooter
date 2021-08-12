extends Camera2D

var MAX_VIEW_DISTANCE := 30.0
var unlocked := false

func _ready():
	yield(get_tree(), "idle_frame")
	set_physics_process(is_network_master())
	current = is_network_master()

func _physics_process(delta):
	if Game.is_paused:
		return
	var parent_pos = get_parent().global_position
	var mouse_pos = get_global_mouse_position()
	var target_pos = (mouse_pos - parent_pos)
	
	global_position = parent_pos + target_pos if unlocked else parent_pos + target_pos.clamped(MAX_VIEW_DISTANCE if Settings.camera_follows_mouse else 0)
