
extends TextureButton

var accessible;

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Apply Settings");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

