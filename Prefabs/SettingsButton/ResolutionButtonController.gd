
extends OptionButton

var accessible;

var resolutions;

var settings;
var displayButton;

func _init():
	var tempresolutions = [];
	tempresolutions.append(Resolution.new(800, 600, "4:3"));
	tempresolutions.append(Resolution.new(1024, 600, "~17:10"));
	tempresolutions.append(Resolution.new(1024, 768, "4:3"));
	tempresolutions.append(Resolution.new(1152, 864, "4:3"));
	tempresolutions.append(Resolution.new(1280, 720, "16:9"));
	tempresolutions.append(Resolution.new(1280, 768, "5:3"));
	tempresolutions.append(Resolution.new(1280, 800, "16:10"));
	tempresolutions.append(Resolution.new(1280, 960, "4:3"));
	tempresolutions.append(Resolution.new(1280, 1024, "5:4"));
	tempresolutions.append(Resolution.new(1360, 768, "~16:9"));
	tempresolutions.append(Resolution.new(1366, 768, "~16:9"));
	tempresolutions.append(Resolution.new(1440, 900, "16:10"));
	tempresolutions.append(Resolution.new(1600, 900, "16:9"));
	tempresolutions.append(Resolution.new(1600, 1200, "4:3"));
	tempresolutions.append(Resolution.new(1680, 1050, "16:10"));
	tempresolutions.append(Resolution.new(1920, 1080, "16:9"));
	tempresolutions.append(Resolution.new(-1, -1, null));
	
	#Remove resolutions that are too big for screen
	var maxScreenSize = Vector2(0,0);
	for s in range(OS.get_screen_count()):
		var screenSize = OS.get_screen_size(s);
		maxScreenSize.x = max(maxScreenSize.x, screenSize.x);
		maxScreenSize.y = max(maxScreenSize.y, screenSize.y);
	
	resolutions = [];
	for res in tempresolutions:
		if(res.Width <= maxScreenSize.x && res.Height <= maxScreenSize.y):
			resolutions.append(res);
						
	#Add items to option box
	for i in range(resolutions.size()):
		add_item(resolutions[i].get_display_string(), i);
	
func _enter_tree():	
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Resolution");
	settings = get_node("/root/GameSettings");
	
	if(settings.windowMode != settings.WINDOW_MODE_FULLSCREEN):
		for i in range(resolutions.size()):
			var res = resolutions[i];
			if(res.Width == settings.screenWidth && res.Height == settings.screenHeight):
				select(i);
				break;
	else:
		select(resolutions.size() - 1);
		set_disabled(true);
			
	displayButton = get_node("../DisplayButton");
	displayButton.connect("item_selected", self, "_on_display_mode_selected");
	displayButton.connect(displayButton.PROGRAMMATIC_ITEM_CHANGED, self, "_on_display_mode_selected");
	_on_display_mode_selected(displayButton.get_selected_ID());
	
func _exit_tree():	
	accessible = AccessibleFactory.clear(accessible);
	displayButton.disconnect("item_selected", self, "_on_display_mode_selected");
	displayButton.disconnect(displayButton.PROGRAMMATIC_ITEM_CHANGED, self, "_on_display_mode_selected");
	
func _on_display_mode_selected(id):
	var windowMode = displayButton.get_selected_window_mode();
	if(windowMode != null && windowMode == settings.WINDOW_MODE_FULLSCREEN):
		select(resolutions.size() - 1);
		set_disabled(true);
	else:
		set_disabled(false);
	
func set_settings():

	if(settings != null):
		var selectedId = get_selected_ID();
		
		if(selectedId >= 0 && selectedId < resolutions.size()):
			var res = resolutions[selectedId];
			
			if(res.Width < 0 && res.Height < 0):
				var screenSize = OS.get_screen_size(OS.get_current_screen());
				settings.screenWidth = screenSize.x;
				settings.screenHeight = screenSize.y;
			else:			
				settings.screenWidth = res.Width;
				settings.screenHeight = res.Height;
	pass

class Resolution:
	var Width;
	var Height;
	var ArString;
	
	func _init(width, height, arString):
		Width = width;
		Height = height;
		ArString = arString;
		
	func get_display_string():
		if(Width < 0 && Height < 0):
			return "Screen Size";
			
		return str(Width) + "x" + str(Height) + " (" + str(ArString) + ")";


