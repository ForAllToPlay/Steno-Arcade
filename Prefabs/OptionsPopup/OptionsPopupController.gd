
extends PopupPanel

const APPLY_SETTINGS = "apply_settings";
const CLOSING = "optionsPopup_closing";

var settings;
var accessible;

var popup;

func _init():
	add_user_signal(APPLY_SETTINGS);
	add_user_signal(CLOSING);

func _ready():	
	set_process(true);
	set_process_unhandled_input(true);
	pass
	
func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Settings");
	settings = get_node("/root/GameSettings");
	
	popup = get_node("Popup");
	popup.connect("about_to_show", self, "show");
	
	get_node("Popup/Panel/GridContainer/ApplyButton").connect("pressed", self, "_apply");
	get_node("Popup/Panel/GridContainer/CancelButton").connect("pressed", self, "_close_popup");
	
	connect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/ResolutionButton"), "set_settings");
	connect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/DisplayButton"), "set_settings");
	connect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/VolumeSlider"), "set_settings");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
	popup.disconnect("about_to_show", self, "show");
	
	get_node("Popup/Panel/GridContainer/ApplyButton").disconnect("pressed", self, "_apply");
	get_node("Popup/Panel/GridContainer/CancelButton").disconnect("pressed", self, "_close_popup");
	
	disconnect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/ResolutionButton"), "set_settings");
	disconnect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/DisplayButton"), "set_settings");
	disconnect(APPLY_SETTINGS, get_node("Popup/Panel/GridContainer/VolumeSlider"), "set_settings");	

func popup():
	popup.popup();
	
func _process(delta):
	#HACK: Check for show/hide here, since the order of events for "popup_hide" 
	# and "about_to_show" seem to cause the overlay to stay hidden
	if(popup.is_hidden() != is_hidden()):
		if(popup.is_hidden()):
			hide();
		else:
			show();

func _close_popup():
	if(get_parent() != null):
		emit_signal(CLOSING);
		get_parent().remove_child(self);

func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):		
		get_tree().set_input_as_handled();
		_close_popup();


func _apply():
	emit_signal(APPLY_SETTINGS);
	
	settings.apply_to_game();
	
	_close_popup();
	pass
	