extends ScrollContainer

func _ready():	
	set_process_input(true);
	pass
	
func _input(event):
	_process_direction(event);
	
func _process_direction(event):	
	var directiony = 0;
	
	if(event.is_action("ui_scroll_up")):
		directiony -= 10;			
	if(event.is_action("ui_scroll_down")):
		directiony += 10;
		
	if(directiony != 0 && is_v_scroll_enabled()):
		set_v_scroll(get_v_scroll() + directiony);
		get_tree().set_input_as_handled();				
		