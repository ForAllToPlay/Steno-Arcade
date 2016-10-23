
extends TextureFrame

var accessible;

func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Results");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);


