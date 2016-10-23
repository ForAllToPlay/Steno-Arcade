
extends Node

const PausePopup = preload("res://Steno Hero/Prefabs/PausePopup/PausedPopup.scn");

var gameController;
var musicPlayer;

var popup;

var textInput;

func _ready():
	gameController = get_node("/root/StenoHeroGame");
	musicPlayer = get_node("/root/StenoHeroGame/MusicPlayer");
	textInput = get_node("../TextInput");
	
	set_process_unhandled_input(true);	
	
func _unhandled_input(event):
	if(!gameController.Finished && event.is_pressed() && event.is_action("ui_cancel")):
		if(!get_tree().is_paused()):		
			get_tree().set_input_as_handled();
			var paused = !get_tree().is_paused();			
			_set_pause_mode(paused);
			
func _set_pause_mode(paused):
	get_tree().set_pause(paused);
	musicPlayer.set_paused(paused);
	
	if (paused):
		if(popup != null):
			popup.close_popup();
		popup = PausePopup.instance();
		popup.connect(popup.POPUP_CLOSING, self, "_on_popup_closing");
		add_child(popup);
		popup.popup();
	else:
		if(popup != null):
			popup.close_popup();
			popup = null;

func _on_popup_closing():
	popup = null;
	_set_pause_mode(false);