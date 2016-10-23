
extends TextureFrame

var util = preload("res://Scripts/Utility.gd");
var animationPlayer;
var flickerTimer;

func _ready():
	animationPlayer = get_node("AnimationPlayer");
	animationPlayer.connect("finished", self, "animationFinished");
	
	flickerTimer = -1;
	
	set_process(true);
	pass
	
func _process(delta):
	if(flickerTimer > 0):
		flickerTimer -= delta;
		if(flickerTimer < 0):
			animationPlayer.play("Flicker");

func animationFinished():
	flickerTimer = util.randfRange(7, 10);	


