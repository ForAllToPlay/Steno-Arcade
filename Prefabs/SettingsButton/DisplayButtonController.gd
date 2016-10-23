

extends OptionButton

const PROGRAMMATIC_ITEM_CHANGED = "programmatic_item_changed";

var accessible;
var displayModes;

var settings;

func _init():
	add_user_signal(PROGRAMMATIC_ITEM_CHANGED);
	
func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Display Mode");
	settings = get_node("/root/GameSettings");
	
	displayModes = [];
	displayModes.append(DisplayMode.new("Window", settings.WINDOW_MODE_WINDOW));
	#"""Not supported:"""  displayModes.append(DisplayMode.new("Borderless Window", settings.WINDOW_MODE_BORDERLESS_WINDOW));
	displayModes.append(DisplayMode.new("Fullscreen", settings.WINDOW_MODE_FULLSCREEN));
	
	clear();
	for i in range(displayModes.size()):
		add_item(displayModes[i].get_display_string(), i);
		if(displayModes[i].Value == settings.windowMode):
			select(i);
			emit_signal(PROGRAMMATIC_ITEM_CHANGED, i);
			
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
func get_selected_window_mode():
	if(displayModes == null):
		return null;
			
	var selectedId = get_selected_ID();
		
	if(selectedId >= 0 && selectedId < displayModes.size()):
		return displayModes[selectedId].Value;
		
	return null;
		
func set_settings():

	if(settings != null):
		var selectedId = get_selected_ID();
		
		if(selectedId >= 0 && selectedId < displayModes.size()):
			var mode = displayModes[selectedId];
			settings.windowMode = mode.Value;
	pass
	

class DisplayMode:
	var DisplayString;
	var Value;
	
	func _init(displayString, value):
		DisplayString = displayString;
		Value = value;
		
	func get_display_string():
		return DisplayString;



