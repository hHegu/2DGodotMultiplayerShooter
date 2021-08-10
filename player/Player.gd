extends Actor

var MAX_HEALTH := 100

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var tween: Tween = $Tween
onready var hp_bar: TextureProgress = $HPBar
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var respawn_timer: Timer = $RespawnTimer

enum {
	weapon1,
	weapon2
}

var death_effect = preload("res://player/DeathEffect.tscn")

var health := MAX_HEALTH
var direction = Vector2()
var is_dead := false

signal on_death
signal on_respawn

func _ready():
	$DisplayUsername.text = Network.username
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	
	set_physics_process(is_network_master())
	$Controlled.visible = is_network_master()
	
	_on_network_peer_connected("")
	hp_bar.value = health

func _on_network_peer_connected(id):
	if is_network_master():
		rpc("share_name", $DisplayUsername.text)

remotesync func share_name(data):
	$DisplayUsername.text = data

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
	is_dead = true
	visible = false
	var death_effect_instance = death_effect.instance()
	death_effect_instance.global_position = global_position
	get_parent().add_child(death_effect_instance)
	emit_signal("on_death")
	if is_network_master():
		respawn_timer.start()


func _physics_process(delta):
	if is_dead:
		return
	var horizontal_movement := handle_horizontal_movement()
	var vertical_movement := handle_jumps()
	direction = Vector2(horizontal_movement, vertical_movement)

	_velocity = calculate_move_velocity(_velocity, direction, speed)
	var snap: Vector2 = Vector2.DOWN * 4.0 if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(_velocity, snap, FLOOR_NORMAL, true, 4, PI / 4, false)
	
	handle_animations()
	rpc_unreliable("position", position)


func handle_horizontal_movement() -> float:
	var horizontal_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	return horizontal_input
	
func handle_jumps() -> float:	
	var vertical_input = (
		-Input.get_action_strength("jump")
		if Input.is_action_just_pressed("jump") and is_on_floor()
		else 0.0
	)
	
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
	if (global_position - get_global_mouse_position()).x > 0:
		animated_sprite.scale.x = -1
	else:
		animated_sprite.scale.x = 1
	
	if anim != animated_sprite.animation || current_scale_x != animated_sprite.scale.x:
		animated_sprite.play(anim)
		rpc_unreliable("play_anim_sync", anim, animated_sprite.scale.x)


func on_hit(damage: int):
	rpc("set_health", health - damage)


func _on_RespawnTimer_timeout():
	rpc("respawn", Network.get_spawn_location().global_position)
	pass # Replace with function body.
