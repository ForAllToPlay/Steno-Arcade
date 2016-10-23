
extends TextureButton

var accessible;
var prompt = "";
const buttonName = "Yes";

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, _get_accessible_name());
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);	
	
func _get_accessible_name():
	return buttonName + ", " + prompt;
	
func set_prompt(val):
	prompt = val;
	if(accessible != null):
		accessible.set_name(_get_accessible_name());


