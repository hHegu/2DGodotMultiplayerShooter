extends Node2D

onready var anim: AnimationPlayer = $AnimationPlayer
onready var shoot_point: Position2D = $Node2D/ShootPoint
var bullet = preload("projectiles/Bullet.tscn")

export var fire_rate := 0.1
export var bullet_lifetime := 2.0
export var bullets_fired := 1
export var accuracy := 1.0
export var damage := 10
export var speed := 8.0
export var bullet_speed_randomness := 0.0

var disabled := false

var SHOOT_RANGE = 300

var fire_timer: Timer

var mouse_pos = Vector2()
var target_pos = Vector2()
var player_pos = Vector2()

signal has_shot

func _ready():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	add_child(fire_timer)

	yield(get_tree(), "idle_frame")
	set_physics_process(is_network_master())


remotesync func look_at_position(pos):
	look_at(pos)

remotesync func shoot(to, id, r, bullet_speed):
	anim.play("fire")
	var bullet_instance = bullet.instance()
	bullet_instance.name = "bullet_{id}_{r}".format({"id": id, "r": r})
	bullet_instance.global_position = shoot_point.global_position
	bullet_instance.dir = (to - shoot_point.global_position).normalized()
	bullet_instance.set_network_master(id)
	bullet_instance.lifetime = bullet_lifetime
	bullet_instance.damage = damage
	bullet_instance.speed = bullet_speed
	get_parent().get_parent().get_parent().get_parent().get_parent().add_child(bullet_instance)
	
func toggle_visibility(is_visible: bool):
	disabled = !is_visible
	visible = is_visible

func _physics_process(delta):
	if disabled:
		return
	mouse_pos = get_global_mouse_position()
	player_pos = get_parent().get_parent().get_parent().get_parent().global_position
	rpc_unreliable("look_at_position", mouse_pos)
	if Input.is_action_pressed("fire") && fire_timer.is_stopped():
		emit_signal("has_shot")
		for n in bullets_fired:
			randomize()
			anim.play("fire")
			var angle = randf() * PI * 2
			randomize()
			var cosrandom = randf()
			randomize()
			var sinrandom = randf()
			target_pos = (mouse_pos - player_pos).normalized() * 50 + player_pos
			var final_pos = target_pos + Vector2(cos(angle) * accuracy * cosrandom, sin(angle) * accuracy * sinrandom)
			var bullet_speed = speed - (speed * randf() * bullet_speed_randomness)
			rpc_unreliable("shoot", final_pos, get_network_master(), randi(), bullet_speed)
		fire_timer.start()

