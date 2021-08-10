extends Node

# Weapons
var w_assault_rifle = preload("res://weapons/AssaultRifle/AssaultRifle.tscn")
var w_shotgun = preload("res://weapons/Shotgun/Shotgun.tscn")

enum weapons_enum {
	assault_rifle,
	shotgun
}

var _weapons_list = {
	weapons_enum.assault_rifle: w_assault_rifle,
	weapons_enum.shotgun: w_shotgun
}

func get_weapon_instance(weapon: int):
	return _weapons_list[weapon].instance()
