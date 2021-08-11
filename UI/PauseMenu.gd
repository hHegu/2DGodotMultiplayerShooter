extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.


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
