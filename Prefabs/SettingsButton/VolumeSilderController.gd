

extends HSlider

var settings;
var accessible;

func _ready():	
	settings = get_node("/root/GameSettings");	
	set_val(settings.soundVolume);
	
func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Sound Volume");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
func set_settings():
	if(settings != null):
		settings.soundVolume = get_val();
	pass
