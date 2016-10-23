
extends TextureFrame

# member variables here, example:
# var a=2
# var b="textvar"
export(bool) var selected = false setget setSelected;

var animator;

func _ready():
	# Initialization here
	animator = get_node("AnimationPlayer");
	pass

func setSelected(newVal):
	selected = newVal;
	if(selected):
		if animator:
			animator.play("FadeUp");
		else:
			set_modulate(Color(1,1,1,1));		
	else:
		if animator:
			animator.play("FadeDown");
		else:
			set_modulate(Color(1,1,1,0));	
	


