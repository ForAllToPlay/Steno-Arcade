
extends PopupPanel

var Score setget set_score;
var Streak setget set_streak;
var Accuracy setget set_accuracy;
var Precision setget set_precision;

const GameInfo = preload("res://Scripts/GameInfo.gd");
const SimplePopup = preload("res://Prefabs/PopupOverlay/SimplePopup.scn");
const util = preload("res://Scripts/Utility.gd");

const CLOSING = "resultsPopup_closing";

var popup;
	
func _init():
	add_user_signal(CLOSING);
	
func _ready():
	popup = get_node("Popup");
	popup.connect("about_to_show", self, "show");
		
	get_node("Popup/PanelContainer/ButtonGrid/NewSong").grab_focus();
	set_process(true);
	pass
	
func _enter_tree():
	get_node("Popup/PanelContainer/ButtonGrid/NewSong").connect("pressed", self, "_return_song_select");
	get_node("Popup/PanelContainer/ButtonGrid/ReplaySong").connect("pressed", self, "_restart_scene");
	get_node("Popup/PanelContainer/ButtonGrid/StenoArcade").connect("pressed", self, "_return_arcade");
	get_node("Popup/PanelContainer/ButtonGrid/ExitToDesktop").connect("pressed", self, "_exit_to_desktop");
	
func _exit_tree():
	get_node("Popup/PanelContainer/ButtonGrid/NewSong").disconnect("pressed", self, "_return_song_select");
	get_node("Popup/PanelContainer/ButtonGrid/ReplaySong").disconnect("pressed", self, "_restart_scene");
	get_node("Popup/PanelContainer/ButtonGrid/StenoArcade").disconnect("pressed", self, "_return_arcade");
	get_node("Popup/PanelContainer/ButtonGrid/ExitToDesktop").disconnect("pressed", self, "_exit_to_desktop");
	
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
	

func set_score(val):
	Score = str(val);
	get_node("Popup/Panel/ResultGrid/Score").set_text(Score);	
	
func set_accuracy(val):
	Accuracy = str(val);
	get_node("Popup/Panel1/ResultGrid1/Accuracy").set_text(Accuracy);
	
func set_streak(val):
	Streak = str(val);
	get_node("Popup/Panel/ResultGrid/Streak").set_text(Streak);
	
func set_precision(val):
	Precision = str(val);
	get_node("Popup/Panel1/ResultGrid1/Precision").set_text(Precision);
	
	
func _restart_scene():
	get_tree().change_scene(GameInfo.StenoHeroGameScene);

func _return_song_select():
	get_tree().change_scene(GameInfo.StenoHeroSplashScreenScene);
	
func _return_arcade():
	get_tree().change_scene(GameInfo.MainSplashScreenScene);
	
func _exit_to_desktop():
	get_tree().quit();