extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var tween: Tween = $Tween
onready var progress: TextureProgress = $VBoxContainer/CenterContainer/TextureProgress
onready var text: RichTextLabel = $TimeText


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.connect("local_player_has_died", self, "_on_player_death")
	tween.connect("tween_all_completed", self, "on_tween_completed")


func _on_player_death():
	visible = true	
	tween.interpolate_property(progress, "value", 100, 0, Game.RESPAWN_TIME)
	tween.start()

func _physics_process(delta):
	var val = progress.value / 100 * Game.RESPAWN_TIME + 1
	text.text =  String(int(val))

func on_tween_completed():
	visible = false
