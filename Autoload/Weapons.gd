extends Node

# Weapons
var w_assault_rifle = preload("res://weapons/AssaultRifle/AssaultRifle.tscn")
var w_shotgun = preload("res://weapons/Shotgun/Shotgun.tscn")
var w_sniper = preload("res://weapons/Sniper/Sniper.tscn")
var w_smg = preload("res://weapons/SMG/SMG.tscn")

enum weapons_enum {
	assault_rifle,
	shotgun,
	sniper,
	smg
}

var _weapons_list = {
	weapons_enum.assault_rifle: w_assault_rifle,
	weapons_enum.shotgun: w_shotgun,
	weapons_enum.sniper: w_sniper,
	weapons_enum.smg: w_smg
}

func get_weapon_instance(weapon: int):
	return _weapons_list[weapon].instance()

func get_random_weapon_indexes():
	var w1 = randi() % _weapons_list.size()
	var w2 = randi() % _weapons_list.size()
	while w1 == w2:
		w2 = randi() % _weapons_list.size()
	
	return [w1, w2]
		
