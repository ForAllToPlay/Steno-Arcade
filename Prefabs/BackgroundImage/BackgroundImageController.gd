
extends TextureFrame

func _ready():

	var screenRef = _get_screen_ref();
			
	if(screenRef != null):
		screenRef.connect(screenRef.SIZE_CHANGED, self, '_on_size_changed');
	
	_on_size_changed(screenRef.get_size(), screenRef.get_size());
	pass
	
func _get_screen_ref():
	var screenRef = get_tree().get_nodes_in_group("ScreenReferences");
	if(screenRef.size() > 0):
		screenRef = screenRef[0];
	else:
		screenRef = null;
	return screenRef;
	
	
func _on_size_changed(newSize, oldSize):
	if(get_texture() == null):
		return;
		
	var texAr = get_texture().get_width() / float(get_texture().get_height());
	var screenAr = newSize.x / float(newSize.y);
	
	var newTexSize;
	if(screenAr > texAr):
		var texWidth = newSize.x;
		var texHeight = texWidth / texAr;
		newTexSize = Vector2(texWidth, texHeight);
	else:
		var texHeight = newSize.y;
		var texWidth = texHeight * texAr;
		newTexSize = Vector2(texWidth, texHeight);
		
	set_size(newTexSize);
	set_pos(Vector2(newSize.x / 2 - newTexSize.x / 2, newSize.y / 2 - newTexSize.y / 2));
	pass

func refresh_size():
	var screenRef = _get_screen_ref();
	if(screenRef != null):
		_on_size_changed(screenRef.get_size(), screenRef.get_size());

func restart_animation():
	get_node("GUIFadeUp").play_fade();