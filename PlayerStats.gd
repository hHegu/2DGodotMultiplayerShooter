extends Node
class_name PlayerStats

var username: String = 'Anonymous'
var health: int = 100 setget set_health

signal health_changed

func set_health(hp):
	emit_signal("health_changed")
	rpc("remote_set_health", hp)

remotesync func remote_set_health(hp):
	health = hp

