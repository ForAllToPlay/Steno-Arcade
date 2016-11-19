
extends PopupPanel

export(String) var LabelText = "";
export(String, FILE) var NextScene = null;

const util = preload("res://Scripts/Utility.gd");

const CLOSING = "lyricsPopup_closing";

var accessible;
var popup;

var SongMetaData;

var headerLabel;
var bodyLabel;

func set_data(songMetaData):
	SongMetaData = songMetaData;
	_set_song_lyrics();
	
func _init():
	add_user_signal(CLOSING);
	
func _ready():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Lyrics");
	popup = get_node("Popup");
	popup.connect("about_to_show", self, "show");
		
	headerLabel = get_node("Popup/Panel/ScrollContainer/PanelContainer/VBoxContainer/Header");
	bodyLabel = get_node("Popup/Panel/ScrollContainer/PanelContainer/VBoxContainer/Body");
		
	set_process(true);
	set_process_unhandled_input(true);
	_set_song_lyrics();	
	pass
	
func _exit_tree():
	get_node("/root/BackgroundMusic").play_default_music();
	accessible = AccessibleFactory.clear(accessible);
	
func _set_song_lyrics():
	if(SongMetaData != null && headerLabel != null && bodyLabel != null):
		if(!util.is_null_or_whitespace(SongMetaData.title)):
			headerLabel.set_text(SongMetaData.title);
		else:
			headerLabel.set_text("Untitled Track");
		
		var song = SongMetaData.generate_song();
		
		if(song != null):
			bodyLabel.set_text(song.get_display_lyrics());		
		
		if(SongMetaData.musicFile != null):
			 get_node("/root/BackgroundMusic").play_song_once(load(SongMetaData.musicFile));

func popup():
	popup.popup();
	
func _process(delta):
	#HACK: Check for show/hide here, since the order of events for "popup_hide" 
	# and "about_to_show" seem to cause the overlay to stay hidden
	if(popup.is_hidden() != is_hidden()):
		if(popup.is_hidden()):
			_close_popup();
		else:
			show();

func _close_popup():
	emit_signal(CLOSING);
	get_parent().remove_child(self);	

func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):		
		get_tree().set_input_as_handled();
		_close_popup();


