
extends TextureFrame

export(String) var Prompt;

var accessible;

func _enter_tree():
	if Prompt != null:
		accessible = AccessibleFactory.recreate_with_name(accessible, self, Prompt);
	else:
		accessible = AccessibleFactory.recreate(accessible, self);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);


