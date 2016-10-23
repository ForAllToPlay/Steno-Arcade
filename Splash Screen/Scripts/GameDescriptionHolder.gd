
extends RichTextLabel

const DEFAULT_TEXT = "Select a game to view information about it.";

var HoverButton;
var FocusButton;

var accessible;

func set_text(text, accessibleText = null):	
	set_bbcode(text);
	
	if(accessibleText == null):
		accessibleText = text;
	accessible.set_name(accessibleText);

func _enter_tree():	
	accessible = AccessibleFactory.recreate_with_name(accessible, self, DEFAULT_TEXT);
	accessible.set_using_popup(true);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
func _ready():
	var buttons = get_tree().get_nodes_in_group("GameButtons");
	for b in buttons:
		b.connect(b.RAW_HOVERED, self, "_on_gameButton_hover");
		b.connect(b.FOCUSED, self, "_on_gameButton_focus");
		
	FocusButton = null;
	HoverButton = null;
	
	set_text(DEFAULT_TEXT);
	pass
	
func _on_gameButton_hover(button, hovered):
	#If a button was just hovered..
	if(hovered):
		HoverButton = button;
		
		#Set the description to match that button
		if(HoverButton):
			set_text(HoverButton.get_display_description(), HoverButton.get_accessible_description());
		else:
			set_text("");
	#If a button lost hover, and it was the last hovered button..
	elif(button == HoverButton):
		#Clear the focus buttons
		HoverButton = null;		
		
		#Set the description to match the focused button, if there is one
		if(FocusButton):
			set_text(FocusButton.get_display_description(), FocusButton.get_accessible_description());
		#If not, use the default text
		else:
			set_text(DEFAULT_TEXT);
	pass
func _on_gameButton_focus(button, focused):	
	#If a button was just focused..
	if(focused):
		FocusButton = button;
		
		#Set the description to match that button
		if(FocusButton):
			set_text(FocusButton.get_display_description(), FocusButton.get_accessible_description());
		else:
			set_text("");
	#If a button lost focus, and it was the last focused button..
	elif(button == FocusButton):
		#Clear the focus buttons
		FocusButton = null;		
		
		#Set the description to match the hovered button, if there is one
		if(HoverButton):
			set_text(HoverButton.get_display_description(), HoverButton.get_accessible_description());
		#If not, use the default text
		else:
			set_text(DEFAULT_TEXT);
	pass


