extends Panel


onready var red_score_text: RichTextLabel = $VBoxContainer/HBoxContainer/red_score
onready var blue_score_text: RichTextLabel = $VBoxContainer/HBoxContainer/blue_score


# Called when the node enters the scene tree for the first time.
func _ready():
	var m := 1;
	set_blue_score(String(Game.blue_score))
	set_red_score(String(Game.red_score))
	Game.connect("score_changed", self, "_on_score_changed")

func _on_score_changed():
	set_blue_score(String(Game.blue_score))
	set_red_score(String(Game.red_score))
	
func set_blue_score(text: String):
	blue_score_text.bbcode_text = "[center]{score}".format({"score": text})
func set_red_score(text: String):
	red_score_text.bbcode_text = "[center]{score}".format({"score": text})
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
