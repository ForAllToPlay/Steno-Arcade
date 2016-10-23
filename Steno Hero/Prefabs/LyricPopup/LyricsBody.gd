
extends Label

var accessible;

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func set_text(val):
	.set_text(val);
	accessible.set_name(val);