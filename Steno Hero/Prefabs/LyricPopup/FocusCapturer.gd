 	
extends TextureButton

var accessible;

var scrollContainer;

func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Close");	
	grab_focus();
	
	scrollContainer = get_node("../Panel/ScrollContainer");
		
	set_process_input(true);
	pass
	
func _enter_tree():
	connect("pressed", self, "close_window");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	disconnect("pressed", self, "close_window");

func _input_event(event):
	_process_close(event);
	_process_direction(event);

func _process_close(event):
	if(!event.is_action("ui_more_info")):
		return;
		
	if(!event.is_pressed()):
		return;
		
	if(event.is_echo()):
		return;
		
	get_tree().set_input_as_handled();
	close_window();
	
func _process_direction(event):
	var directionx = 0;
	var directiony = 0;
	
	if(event.is_action("ui_up")):
		directionx -= 5;
	if(event.is_action("ui_down")):
		directionx += 5;
	if(event.is_action("ui_left")):
		directiony -= 5;
	if(event.is_action("ui_right")):
		directiony += 5;
	if(event.is_action("ui_page_up") && event.is_pressed()):
		directionx -= scrollContainer.get_size().y;
	if(event.is_action("ui_page_down") && event.is_pressed()):
		directionx += scrollContainer.get_size().y;
		
	if(scrollContainer != null):
		if(directionx != 0 && scrollContainer.is_v_scroll_enabled()):
			scrollContainer.set_v_scroll(scrollContainer.get_v_scroll() + directionx);
			accept_event();
		if(directiony != 0 && scrollContainer.is_h_scroll_enabled()):
			scrollContainer.set_h_scroll(scrollContainer.get_h_scroll() + directiony);
			accept_event();
	
	
func close_window():
	get_parent().hide();

	