
extends Button

var SongMetaData setget _set_song_data;
var ExtraPadding;

const LyricPopup = preload("res://Steno Hero/Prefabs/LyricPopup/LyricPopup.scn");

var StenoHeroGlobals;

const HOVERED = "songButton_hovered";
const FOCUSED = "songButton_focus";

var lastHovered;
var lastFocused;

var accessible;

func _init():
	add_user_signal(HOVERED);
	add_user_signal(FOCUSED);	

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	StenoHeroGlobals = get_node('/root/StenoHeroGlobals');
	
	connect("pressed", self, "_on_songButton_pressed");
	connect("input_event", self, "_on_input_event");
		
	set_process(true);	
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
		
func _process(delta):
	_update_state_signals();

func _update_state_signals():
	var hovered = is_hovered();
	if(hovered != lastHovered):
		lastHovered = hovered;
		emit_signal(HOVERED, self, lastHovered);
		
	var focused = has_focus();
	if(focused != lastFocused):
		lastFocused = focused;
		emit_signal(FOCUSED, self, lastFocused);
		
func _set_song_data(val):
	SongMetaData = val;
	
	if(SongMetaData != null):
		set_text(SongMetaData.get_display_string());
	pass

func _on_songButton_pressed():
	if(!has_focus()):
		return;	
	
	var fader = get_tree().get_nodes_in_group("SceneFaders");
	if(fader.size() > 0):
		fader = fader[0];
	else:
		fader = null;
		
	StenoHeroGlobals.start_song(SongMetaData, fader);	
