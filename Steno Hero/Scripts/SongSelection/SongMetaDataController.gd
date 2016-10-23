
extends VBoxContainer

const METADATA_CHANGED = "METADATA_CHANGED";
const METADATA_CLEARED = "METADATA_CLEARED";

var HoverButton;
var FocusButton;

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
		b.connect(b.VIEWING_LYRICS, self, "_on_songButton_viewingLyrics");
		
	FocusButton = null;
	HoverButton = null;
	
	pass


func _on_songButton_hover(button, hovered):
	#If a button was just hovered..
	if(hovered):
		HoverButton = button;
		
		if(HoverButton != null):
			self.metaData = HoverButton.SongMetaData;
		else:
			self.metaData = LyricsViewMetaData;
	#If a button lost hover, and it was the last hovered button..
	elif(button == HoverButton):
		#Clear the focus buttons
		HoverButton = null;		
		
		if(FocusButton != null):
			self.metaData = FocusButton.SongMetaData;
		else:
			self.metaData = LyricsViewMetaData;
	
func _on_songButton_focus(button, focused):	
	#If a button was just focused..
	if(focused):
		FocusButton = button;
		
		if(FocusButton != null):
			self.metaData = FocusButton.SongMetaData;
		else:
			self.metaData = LyricsViewMetaData;
	#If a button lost focus, and it was the last focused button..
	elif(button == FocusButton):
		#Clear the focus buttons
		FocusButton = null;		
		
		if(HoverButton != null):
			self.metaData = HoverButton.SongMetaData;
		else:
			self.metaData = LyricsViewMetaData;
	pass
	
func _on_songButton_viewingLyrics(button, viewing):
	if(viewing):
		LyricsViewMetaData = button.SongMetaData;
	else:
		LyricsViewMetaData = null;
	
	self.metaData = LyricsViewMetaData;

func _set_meta_data(val):
	metaData = val;
	if(val != null):
		emit_signal(METADATA_CHANGED, val);
	else:
		emit_signal(METADATA_CLEARED);


