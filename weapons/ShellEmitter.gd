extends Node2D

#var shell = preload("res://weapons/projectiles/ShotgunShell.tscn")
export(PackedScene) var shell
export(Texture) var shell_texture

func spawn_shell():
	var player = get_parent().get_parent().get_parent().get_parent()
	var dir = (Vector2.UP - (Vector2.RIGHT * player.scale.x)).normalized()
	
	var shell_i = shell.instance()
	shell_i.set_texture(shell_texture)
	shell_i.apply_impulse(Vector2.ZERO, dir * 30)
	shell_i.global_position = global_position
	shell_i.angular_velocity = 20.0
	
	player.get_parent().get_parent().add_child(shell_i)
