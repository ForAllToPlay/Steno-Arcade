
extends PopupPanel

var popup;

const POPUP_CLOSING = "pausedpopup_closing";

const GameInfo = preload("res://Scripts/GameInfo.gd");
const SimplePopup = preload("res://Prefabs/PopupOverlay/SimplePopup.scn");

var resumeGameButton;
var restartSongButton;
var songSelectionButton;
var stenoArcadeButton;
var exitToDesktopButton;

func _init():
	add_user_signal(POPUP_CLOSING);
	
func _ready():
	popup = get_node("Popup");
	popup.connect("about_to_show", self, "show");
	
	resumeGameButton = get_node("Popup/Panel/Container/ResumeGame");
	restartSongButton = get_node("Popup/Panel/Container/RestartSong");
	songSelectionButton = get_node("Popup/Panel/Container/SongSelection");
	stenoArcadeButton = get_node("Popup/Panel/Container/StenoArcade");
	exitToDesktopButton = get_node("Popup/Panel/Container/ExitToDesktop");
	
	resumeGameButton.connect("pressed", self, "_resume_game");	
	restartSongButton.connect("pressed", self, "_restart_scene");	
	songSelectionButton.connect("pressed", self, "_return_song_select");	
	stenoArcadeButton.connect("pressed", self, "_return_arcade");	
	exitToDesktopButton.connect("pressed", self, "_exit_to_desktop");	
	
	resumeGameButton.grab_focus();
	
	set_process(true);
	set_process_unhandled_input(true);
	pass

func popup():
	popup.popup();
	
func _process(delta):
	#HACK: Check for show/hide here, since the order of events for "popup_hide" 
	# and "about_to_show" seem to cause the overlay to stay hidden
	if(popup.is_hidden() != is_hidden()):
		if(popup.is_hidden()):
			hide();
		else:
			show();

func close_popup():
	emit_signal(POPUP_CLOSING);
	if(get_parent() != null):
		get_parent().remove_child(self);

func _show_simple_popup(prompt, promptImage, nextScene, sourceButton):
	var newPopup = SimplePopup.instance();
	newPopup.PromptTexture = promptImage;
	newPopup.NextScene = nextScene;
	newPopup.LabelText = prompt;
	newPopup.connect(newPopup.CLOSING, sourceButton, "grab_focus");
		
	add_child(newPopup);	
	newPopup.popup();
	
func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):		
		get_tree().set_input_as_handled();		
		close_popup();

func _resume_game():
	close_popup();
	
func _restart_scene():
	_show_simple_popup("Restart this song", preload("res://Steno Hero/Sprites/Headings/RestartSong.tex"), GameInfo.StenoHeroGameScene, restartSongButton);

func _return_song_select():
	_show_simple_popup("Return to song selection", preload("res://Steno Hero/Sprites/Headings/ReturnToSongSelection.tex"), GameInfo.StenoHeroSplashScreenScene, songSelectionButton);
	
func _return_arcade():
	_show_simple_popup("Return to the main screen", preload("res://Sprites/Headings/ReturnToStenoArcade.tex"), GameInfo.MainSplashScreenScene, stenoArcadeButton);
	
func _exit_to_desktop():
	_show_simple_popup("Exit to desktop", preload("res://Sprites/Headings/ExitToDesktop.tex"), null, exitToDesktopButton);
	