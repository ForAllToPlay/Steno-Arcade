extends TextureButton

const OptionsPopup = preload("res://Prefabs/OptionsPopup/OptionsPopup.scn");

var popup;
var accessible;

func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Settings");
	popup = OptionsPopup.instance();
	popup.connect(popup.CLOSING, self, "grab_focus");
		
	connect("pressed", self, "_pressed");
	pass
	
func _pressed():
	if(popup == null):
		return;
	
	var parent = get_node("../../../..");
	
	if(popup.get_parent() != parent):
		if(popup.get_parent() != null):
			popup.get_parent().remove_child(popup);
		parent.add_child(popup);
	popup.popup();

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

