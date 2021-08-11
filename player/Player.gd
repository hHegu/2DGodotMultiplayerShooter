extends Actor

var MAX_HEALTH := 100
var MAX_JUMPS = 1

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var tween: Tween = $Tween
onready var hp_bar: TextureProgress = $HPBar
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var respawn_timer: Timer = $RespawnTimer
onready var coyote_timer: Timer = $CoyoteTimer
onready var jump_predict_timer: Timer = $JumpPredictTimer
onready var one_way_detector: RayCast2D = $OneWayDetector
onready var flag_holder = $AnimatedSprite/FlagHandler

var death_effect = preload("res://player/DeathEffect.tscn")

var health := MAX_HEALTH
var direction = Vector2()
var is_dead := false

var jumps = MAX_JUMPS

signal on_death
signal on_respawn

func _ready():
#	var player = Lobby.players[get_network_master()]
#	$DisplayUsername.text = Network.username
#	$DisplayUsername.modulate = Color.red if player.team == "red" else Color.cyan
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	connect("unfloored", self, "on_unfloored")
	
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	
	set_physics_process(is_network_master())
	$Controlled.visible = is_network_master()
	
	_on_network_peer_connected("")
	hp_bar.value = health
	
	respawn_timer.wait_time = Game.RESPAWN_TIME
	
	if is_network_master():
		var me = Lobby.players[get_network_master()]
		rpc("share_name", me.username, me.team)


func _on_network_peer_connected(id):
	if is_network_master():
		var player = Lobby.players[get_network_master()]
		rpc("share_name", player.username, player.team)

remotesync func share_name(data, team):
	$DisplayUsername.text = data
	$DisplayUsername.modulate = Color.red if team == "red" else Color.cyan

remotesync func position(pos: Vector2):
#	global_position = pos
	tween.interpolate_property(self, "global_position", global_position, pos, 0.04)
	tween.start()


remotesync func play_anim_sync(anim, scale_x):
	animated_sprite.scale.x = scale_x
	animated_sprite.play(anim)


remotesync func set_health(hp):
	health = hp
	hp_bar.value = health
	animation_player.play("hit")
	if health <= 0:
		die()


remotesync func respawn(pos: Vector2):
	global_position = pos
	is_dead = false
	visible = true
	set_health(MAX_HEALTH)
	emit_signal("on_respawn")


func die():
	emit_signal("on_death")
	is_dead = true
	visible = false
	var death_effect_instance = death_effect.instance()
	death_effect_instance.global_position = global_position
	get_parent().add_child(death_effect_instance)
	if is_network_master():
		Game.emit_signal("local_player_has_died")
		respawn_timer.start()


func _physics_process(delta):
	if is_dead:
		return
	
	if is_floored:
		jumps = MAX_JUMPS
	
	var horizontal_movement := handle_horizontal_movement()
	var vertical_movement := handle_jumps()
	direction = Vector2(horizontal_movement, vertical_movement)

	_velocity = calculate_move_velocity(_velocity, direction, speed)
	
	if Input.is_action_just_released("jump"):
		if _velocity.y < -100:
			_velocity.y = -100
	
	var snap: Vector2 = Vector2.DOWN * 4.0 if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(_velocity, snap, FLOOR_NORMAL, true, 4, PI / 4, false)
	
	if Input.is_action_pressed("move_down") && one_way_detector.is_colliding():
		position = position + Vector2.DOWN
		
	
	handle_animations()
	rpc_unreliable("position", position)


func handle_horizontal_movement() -> float:
	var horizontal_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	return horizontal_input
	
func handle_jumps() -> float:
	var can_jump = (is_on_floor() or !coyote_timer.is_stopped()) and jumps > 0
	
	var pressed_jump = Input.is_action_just_pressed("jump")
	var vertical_input = (
		-Input.get_action_strength("jump")
		if (pressed_jump or !jump_predict_timer.is_stopped()) and can_jump
		else 0.0
	)
	
	var jumped_successfully = vertical_input < 0
	if jumped_successfully:
		jump_predict_timer.stop()
		jumps -= 1;
		
	if pressed_jump && !jumped_successfully:
		jump_predict_timer.start()
	
	return vertical_input
	
func calculate_move_velocity(linear_velocity: Vector2, direction: Vector2, speed: Vector2) -> Vector2:
	var velocity := linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	return velocity


func handle_animations() -> void:
	if is_on_floor() and abs(_velocity.x) > 0:
		play_anim('walk')

	if is_on_floor() and abs(_velocity.x) == 0:
		play_anim('idle')

	if not is_on_floor() and _velocity.y < 0:
		play_anim('jump_up')
		
	if not is_on_floor() and _velocity.y > 0:
		play_anim('jump_down')
		
func play_anim(anim: String, replay_if_already_playing := false):
	var current_scale_x = animated_sprite.scale.x
	if !Game.is_paused:
		handle_flip()
	if anim != animated_sprite.animation || current_scale_x != animated_sprite.scale.x:
		animated_sprite.play(anim)
		rpc_unreliable("play_anim_sync", anim, animated_sprite.scale.x)


func on_hit(damage: int):
	rpc("set_health", health - damage)

func handle_flip():
	if (global_position - get_global_mouse_position()).x > 0:
		animated_sprite.scale.x = -1
	else:
		animated_sprite.scale.x = 1

func _on_RespawnTimer_timeout():
	var id = get_tree().get_network_unique_id()
	var team = Lobby.players[id]["team"]
	rpc("respawn", Network.get_spawn_location(team).global_position)

func on_unfloored():
	coyote_timer.stop()
	coyote_timer.start()


func _on_CoyoteTimer_timeout():
	jumps -= 1
