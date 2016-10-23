
extends TextureButton

export(Texture) var PopupPromptImage;
export(String) var PopupPrompt;
export(String) var ButtonName;
export(String, FILE) var PopupScene;

const SimplePopup = preload("res://Prefabs/PopupOverlay/SimplePopup.scn");

var popup;
var accessible;

func _enter_tree():	
	if(ButtonName != null):
		accessible = AccessibleFactory.create_with_name(self, ButtonName);
	else:
		accessible = AccessibleFactory.create(self);
	accessible.set_using_popup(true);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func _ready():	
	popup = SimplePopup.instance();	
	popup.PromptTexture = PopupPromptImage;
	popup.LabelText = PopupPrompt;
	popup.NextScene = PopupScene;
	popup.connect(popup.CLOSING, self, "grab_focus");
		
	connect("pressed", self, "_pressed");
	set_process_unhandled_input(true);
	pass
	
func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):
		_pressed();
		get_tree().set_input_as_handled();
	
func _pressed():
	if(popup == null):
		return;
		
	
	if(popup.get_parent() != get_parent()):
		if(popup.get_parent() != null):
			popup.get_parent().remove_child(popup);
		get_parent().add_child(popup);
	popup.popup();


