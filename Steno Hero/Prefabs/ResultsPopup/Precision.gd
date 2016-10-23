
extends Label

var accessible;

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
