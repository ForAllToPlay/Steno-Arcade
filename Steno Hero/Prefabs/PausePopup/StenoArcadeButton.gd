
extends TextureButton

var accessible;

func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Steno Arcade");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

