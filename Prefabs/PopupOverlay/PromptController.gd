
extends Label

var accessible;

func _enter_tree():
	accessible = AccessibleFactory.recreate(accessible, self);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

