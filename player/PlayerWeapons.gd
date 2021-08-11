extends Node2D


onready var slot_1 = $WeaponSlot1
onready var slot_2 = $WeaponSlot2

var my_weapons = [
	Weapons.w_shotgun,
	Weapons.w_sniper
]

var current_weapon := 0
var disabled := false


func _ready():

	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")

	set_physics_process(is_network_master())

	get_parent().get_parent().connect("on_death", self, "_on_death")
	get_parent().get_parent().connect("on_respawn", self, "enable_weapons")

	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	
	if is_network_master():
		rpc("randomize_weapons", get_network_master(), Weapons.get_random_weapon_indexes())
	
	
func _physics_process(delta):
	if disabled:
		return
	var weapon_1_pressed = Input.is_action_just_pressed("weapon_1")
	var weapon_2_pressed = Input.is_action_just_pressed("weapon_2")
	if weapon_1_pressed && current_weapon != 0 || weapon_2_pressed && current_weapon != 1:
		rpc("switch_weapon", 0 if current_weapon == 1 else 1)


func _on_death():
	if is_network_master():
		rpc("randomize_weapons", get_network_master(), Weapons.get_random_weapon_indexes())
	disable_weapons()


func _on_network_peer_connected(id):
	if is_network_master():
		rpc_id(id, "randomize_weapons", get_network_master(), my_weapons)


func disable_weapons():
	disabled = true
	for w1 in slot_1.get_children():
		w1.toggle_visibility(false)
	for w2 in slot_2.get_children():
		w2.toggle_visibility(false)


func enable_weapons():
	disabled = false
	for w1 in slot_1.get_children():
		w1.toggle_visibility(current_weapon == 0)
	for w2 in slot_2.get_children():
		w2.toggle_visibility(current_weapon == 1)


remotesync func randomize_weapons(id, weapons):
	my_weapons = weapons
	for w1 in slot_1.get_children():
		slot_1.remove_child(w1)
		w1.queue_free()
	for w2 in slot_2.get_children():
		slot_2.remove_child(w2)
		w2.queue_free()

	var w1_instance = Weapons.get_weapon_instance(weapons[0])
	var w2_instance = Weapons.get_weapon_instance(weapons[1])
	
	w2_instance.toggle_visibility(false)
	
	w1_instance.set_network_master(id)
	w2_instance.set_network_master(id)
	
	slot_1.add_child(w1_instance)
	slot_2.add_child(w2_instance)


remotesync func switch_weapon(wi):
	current_weapon = wi
	for w1 in slot_1.get_children():
		w1.toggle_visibility(current_weapon == 0)
	for w2 in slot_2.get_children():
		w2.toggle_visibility(current_weapon == 1)
	
