extends PanelContainer

var accessible;

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Credits");
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func _ready():
	accessible.set_name(getCreditString());
	
	#set_focus_mode(FOCUS_ALL);
	#grab_focus();
	
	pass
	
func getCreditString():
	var credits = "";
	
	var container = get_node("VBoxContainer");
	for child in container.get_children():
		credits += child.get_text();
	
	return credits;