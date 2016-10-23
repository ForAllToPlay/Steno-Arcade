
extends TextureFrame

# member variables here, example:
# var a=2
# var b="textvar"
var screenRect;


func _ready():
	# Initialization here
	screenRect = get_viewport_rect();
	
	#set_pos(screenRect.pos);
	#set_size(screenRect.size);
	#print(screenRect.size);
	#set_expand(true);
	pass


