
extends VBoxContainer

const METADATA_CHANGED = "METADATA_CHANGED";
const METADATA_CLEARED = "METADATA_CLEARED";
const LyricPopup = preload("res://Steno Hero/Prefabs/LyricPopup/LyricPopup.scn");

var HoverButton;
var FocusButton;

var LyricPopupInstance;
var LyricTriggerButton;
var LyricsViewMetaData;

var metaData = null setget _set_meta_data;

func _init():
	add_user_signal(METADATA_CHANGED);
	add_user_signal(METADATA_CLEARED);
	
func _ready():
	var buttons = get_tree().get_nodes_in_group("SongButtons");
	
	for b in buttons:
		b.connect(b.HOVERED, self, "_on_songButton_hover");
		b.connect(b.FOCUSED, self, "_on_songButton_focus");
		
	FocusButton = null;
	HoverButton = null;
	
	set_process_input(true);
	pass
	
func _input(event):
	_show_lyrics(event);

func _show_lyrics(ev):		
	
	if(!ev.is_action("ui_more_info")):
		return;
		
	if(!ev.is_pressed()):
		return;
		
	if(ev.is_echo()):
		return;	
	
	if(LyricPopupInstance  == null):		
		if(self.metaData == null):
			return;		
		
		if(HoverButton != null):
			LyricTriggerButton = HoverButton;
		else:
			LyricTriggerButton = FocusButton;
			
		var screenRefs = get_tree().get_nodes_in_group("ScreenReferences");
		if(screenRefs.size() > 0):		
			var popup = LyricPopup.instance();	
			popup.set_data(metaData);	
			popup.connect(popup.CLOSING, self, "_on_popup_closing");
			
			screenRefs[0].add_child(popup);
			popup.popup();		
			
			LyricPopupInstance = popup;
			get_tree().set_input_as_handled();		
	else:
		LyricPopupInstance.close_popup();
		LyricPopupInstance = null;
		get_tree().set_input_as_handled();		
		
func _on_popup_closing():
	if(LyricTriggerButton != null):
		LyricTriggerButton.grab_focus();
		LyricTriggerButton = null;	
	LyricPopupInstance = null;

func _on_songButton_hover(button, hovered):
	#If a button was just hovered..
	if(hovered):
		HoverButton = button;
		
		if(HoverButton != null):
			self.metaData = HoverButton.SongMetaData;
		else:
			self.metaData = null;
	#If a button lost hover, and it was the last hovered button..
	elif(button == HoverButton):
		#Clear the focus buttons
		HoverButton = null;		
		
		if(FocusButton != null):
			self.metaData = FocusButton.SongMetaData;
		else:
			self.metaData = null;
	
func _on_songButton_focus(button, focused):	
	#If a button was just focused..
	if(focused):
		FocusButton = button;
		
		if(FocusButton != null):
			self.metaData = FocusButton.SongMetaData;
		else:
			self.metaData = null;
	#If a button lost focus, and it was the last focused button..
	elif(button == FocusButton):
		#Clear the focus buttons
		FocusButton = null;		
		
		if(HoverButton != null):
			self.metaData = HoverButton.SongMetaData;
		else:
			self.metaData = null;
	pass	

func _set_meta_data(val):
	metaData = val;
	if(val != null):
		emit_signal(METADATA_CHANGED, val);
	else:
		emit_signal(METADATA_CLEARED);


