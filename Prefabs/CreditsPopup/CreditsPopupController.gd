
extends PopupPanel

const util = preload("res://Scripts/Utility.gd");

const CLOSING = "creditsPopup_closing";

var accessible;

var popup;
func get_popup():
	if(popup == null):
		popup = get_node("Popup");
	return popup;
	
func _init():
	add_user_signal(CLOSING);
	
func _ready():
	set_process(true);
	set_process_unhandled_input(true);
	pass
	
func _enter_tree():
	accessible = AccessibleFactory.create_with_name(self, "Credits Dialog");
	get_popup().connect("about_to_show", self, "show");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	get_popup().disconnect("about_to_show", self, "show");
	
func popup():
	get_popup().popup();
	
func _process(delta):
	#HACK: Check for show/hide here, since the order of events for "popup_hide" 
	# and "about_to_show" seem to cause the overlay to stay hidden
	if(get_popup().is_hidden() != is_hidden()):
		if(get_popup().is_hidden()):
			_close_popup();
		else:
			show();

func _close_popup():
	emit_signal(CLOSING);
	get_parent().remove_child(self);
	
func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):		
		get_tree().set_input_as_handled();
		_close_popup();

	

