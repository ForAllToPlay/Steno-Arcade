
extends TextureFrame

var accessible;

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Steno Hero");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);