
extends Sprite

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	var screenRef = get_node("/root/StenoHeroGame/ScreenRef");
	screenRef.connect(screenRef.SIZE_CHANGED, self, "_set_size");

	_set_size(screenRef.get_size(), screenRef.get_size());
	pass
	
func _set_size(screenSize, oldSize):
	var oldRegionRect = get_region_rect();	
	set_region_rect(Rect2(oldRegionRect.pos.x, oldRegionRect.pos.y, screenSize.x, oldRegionRect.size.y));
	pass


