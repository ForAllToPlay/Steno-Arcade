
extends TextureButton

const OptionsPopup = preload("res://Prefabs/OptionsPopup/OptionsPopup.scn");

export(bool) var AnimateIn = true setget set_animate_in;

var popup;
var accessible;

func _enter_tree():	
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Settings");
	accessible.set_using_popup(true);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
func _ready():
	popup = OptionsPopup.instance();
	popup.connect(popup.CLOSING, self, "grab_focus");
		
	connect("pressed", self, "_pressed");
	
	set_animate_in(AnimateIn);
	pass
	
func _pressed():
	if(popup == null):
		return;
	
	if(popup.get_parent() != get_parent()):
		if(popup.get_parent() != null):
			popup.get_parent().remove_child(popup);
		get_parent().add_child(popup);
	popup.popup();	

func set_animate_in(val):
	AnimateIn = val;
	if(has_node("GUIFadeUp")):	
		var animator = get_node("GUIFadeUp");
		animator.Enabled = val;
		if(!val):
			animator.stop_all();
			set_opacity(1);
