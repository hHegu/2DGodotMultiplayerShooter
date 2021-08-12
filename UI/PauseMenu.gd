extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var camera_follow_checkbox: CheckBox = $SubMenus/Settings/CameraFollowSetting
onready var settings_container: VBoxContainer = $SubMenus/Settings
onready var main_container: VBoxContainer = $SubMenus/MainMenu
onready var sub_menus: Control = $SubMenus


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	camera_follow_checkbox.pressed = Settings.camera_follows_mouse


func toggle_menu():
	if visible:
		visible = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		visible = true
		mouse_filter = Control.MOUSE_FILTER_STOP
	Game.is_paused = visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_menu()
	pass


func _on_ResumeButton_pressed():
	toggle_menu()


func _on_QuitButton_pressed():
	get_tree().quit()


func change_sub_menu(container: String):
	for m in sub_menus.get_children():
		print(m.name)
		m.visible = m.name == container


func _on_SettingsBackButton_pressed():
	change_sub_menu("MainMenu")
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	change_sub_menu("Settings")
	pass # Replace with function body.


func _on_CameraFollowSetting_pressed():
	Settings.camera_follows_mouse = !Settings.camera_follows_mouse
	camera_follow_checkbox.pressed = Settings.camera_follows_mouse
#	Settings.camera_follows_mouse
	
	pass # Replace with function body.
