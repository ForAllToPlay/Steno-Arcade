
extends Label

var accessible;

func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Press tilde to view lyrics for the selected song");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);