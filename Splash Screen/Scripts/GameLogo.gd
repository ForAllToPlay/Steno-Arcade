
extends TextureFrame

var accessible;

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Steno Arcade");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);