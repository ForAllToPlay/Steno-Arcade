
extends TextureFrame

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	
	var screenRect = get_viewport_rect();
	
	set_pos(screenRect.pos);
	set_size(screenRect.size);
	pass


