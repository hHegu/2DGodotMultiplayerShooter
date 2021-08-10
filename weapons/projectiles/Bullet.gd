extends KinematicBody2D

var hit_effect = preload("res://weapons/effects/BulletHitEffect.tscn")

var dir: Vector2
var speed := 8.0
var lifetime := 2.0
var damage := 10
var bullet_color := modulate
var trail_length := 5
var fast_bullet_raycast_enabled := true

onready var timer: Timer = $Timer
onready var trail = $Trail
onready var next_point_raycast: RayCast2D  = $RayCast2D

func _ready():
	yield(get_tree(), "idle_frame")
	set_physics_process(is_network_master())
#	rotation = PI * randf()
	timer.start(lifetime)
	modulate = bullet_color
	trail.set_color(bullet_color)
	trail.trailLength = trail_length
	next_point_raycast.cast_to = dir.normalized() * speed * 1.5
	next_point_raycast.enabled = fast_bullet_raycast_enabled


remotesync func position(data):
	position = data


remotesync func destroy(show_hit_effect = false):
	if show_hit_effect:
		var hit_effect_instance: Particles2D = hit_effect.instance()
		hit_effect_instance.global_position = global_position
		hit_effect_instance.modulate = bullet_color
		var n_dir = dir.normalized()
		hit_effect_instance.process_material.direction = Vector3(n_dir.x, n_dir.y, 0) * -1
		get_parent().add_child(hit_effect_instance)
	queue_free()


func _physics_process(delta):
	var collision = move_and_collide(dir * speed)
	rpc_unreliable('position', position)
	
	if collision && is_network_master():
		rpc('destroy', true)
		return

	var col = next_point_raycast.get_collider()
	if col != null && col.has_method("on_hit"):
		if col.is_dead:
			return
		col.on_hit(damage)
		rpc('destroy', true)
		return

func _on_Timer_timeout():
	if is_network_master():
		rpc('destroy')


func _on_Area2D_body_entered(body: Node2D):
	if is_network_master() and body.get_network_master() != get_network_master():
		if body.has_method("on_hit") && !body.is_dead:
			body.on_hit(damage)
			rpc('destroy', true)

