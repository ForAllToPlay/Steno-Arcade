extends Node

const FILE_LOCATION = "res://Settings.ini";

const SCREEN_WIDTH_NAME = "[Screen Width]";
const SCREEN_HEIGHT_NAME = "[Screen Height]";
const WINDOW_MODE_NAME = "[Window Mode]";
const SOUND_VOLUME_NAME = "[Sound Volume]";

const SETTINGS_DELIMITER = "=";

const WINDOW_MODE_WINDOW = 0;
const WINDOW_MODE_FULLSCREEN = 1;
const WINDOW_MODE_BORDERLESS_WINDOW = 2;

const util = preload("res://Scripts/Utility.gd");

var screenWidth setget set_screen_width;
var screenHeight setget set_screen_height;
var windowMode setget set_window_mode;
var soundVolume setget set_sound_volume;

func set_default_settings():
	screenWidth = 800;
	screenHeight = 600;
	windowMode = WINDOW_MODE_FULLSCREEN;
	soundVolume = 1;

func _init():
	set_default_settings();
	
func _ready():
	load_from_file();
	save_to_file();
	apply_to_game();
	
	pass
	
func set_screen_width(val):
	screenWidth = max(val, 10);
	save_to_file();
	
func set_screen_height(val):
	screenHeight = max(val, 10);
	save_to_file();
	
func set_window_mode(val):
	windowMode = val;
	save_to_file();
	
func set_sound_volume(val):
	soundVolume = clamp(val, 0, 1);
	save_to_file();
	
	
func save_to_file():

	var file = File.new();
	
	file.open(FILE_LOCATION, File.WRITE);
	
	file.store_line(SCREEN_WIDTH_NAME + SETTINGS_DELIMITER + str(screenWidth));
	file.store_line(SCREEN_HEIGHT_NAME + SETTINGS_DELIMITER + str(screenHeight));
	file.store_line(WINDOW_MODE_NAME + SETTINGS_DELIMITER + str(windowMode));
	file.store_line(SOUND_VOLUME_NAME + SETTINGS_DELIMITER + str(soundVolume));
	
	file.close();
	
	pass
	
func load_from_file():
	var file = File.new();
	
	if(!file.file_exists(FILE_LOCATION)):
		return;
	
	file.open(FILE_LOCATION, File.READ);
	
	var line = file.get_line();
	while !file.eof_reached() || !util.is_null_or_whitespace(line):
		
		line = line.strip_edges();
		
		var split = line.split(SETTINGS_DELIMITER, false);
		if(split.size() >= 2):
			split[0] = split[0].strip_edges();
			split[1] = split[1].strip_edges();
			
			if(split[0] == SCREEN_WIDTH_NAME):
			
				var width = split[1].to_int();
				if(width > 0):
					screenWidth = width;
					
			elif(split[0] == SCREEN_HEIGHT_NAME):
			
				var height = split[1].to_int();
				if(height > 0):
					screenHeight = height;
					
			elif(split[0] == WINDOW_MODE_NAME):
				
				var mode = split[1].to_int();
				if(mode >= 0):
					windowMode = mode;
					
			elif(split[0] == SOUND_VOLUME_NAME):
				
				var volume = split[1].to_float();
				if(volume >= 0 && volume <= 1):
					soundVolume = volume;
		
		line = file.get_line();
	
	file.close();	
	
	pass

func apply_to_game():
	var maxScreenSize = OS.get_screen_size(OS.get_current_screen());
	
	if(windowMode == WINDOW_MODE_FULLSCREEN):
		OS.set_window_size(maxScreenSize);
		OS.set_window_fullscreen(true);
	else:	
		OS.set_window_fullscreen(false);	
		OS.set_window_size(Vector2(min(screenWidth, maxScreenSize.x), min(screenHeight, maxScreenSize.y)));
			
		
	var actualWindowSize = OS.get_window_size();
	self.screenWidth = actualWindowSize.x;
	self.screenHeight = actualWindowSize.y;
	
	if(OS.is_window_fullscreen()):
		self.windowMode = WINDOW_MODE_FULLSCREEN;
	else:
		self.windowMode = WINDOW_MODE_WINDOW;
		
	if(windowMode == WINDOW_MODE_WINDOW && screenWidth == maxScreenSize.x && screenHeight == maxScreenSize.y):
		OS.set_window_maximized(true);
		
		
	AudioServer.set_fx_global_volume_scale(soundVolume);
	AudioServer.set_stream_global_volume_scale(soundVolume);
	
	self.soundVolume = AudioServer.get_fx_global_volume_scale();
	
	pass
	