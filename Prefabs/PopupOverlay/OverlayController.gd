
extends PopupPanel

export(Texture) var PromptTexture = null setget set_prompt_texture;
export(String) var LabelText = "";
export(PackedScene) var NextScene = null;

const CLOSING = "simplePopup_closing";

var popup;
var accessible;

func _init():
	add_user_signal(CLOSING);		

func _ready():		
	set_process(true);
	set_process_unhandled_input(true);
	pass

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, "Confirmation");	
	popup = get_node("Popup");
	popup.connect("about_to_show", self, "show");
	
	set_prompt_texture(PromptTexture);
	set_prompt_text(LabelText);
		
	get_node("Popup/Panel/YesButton").connect("pressed", self, "_go_to_next_scene");
	get_node("Popup/Panel/NoButton").connect("pressed", self, "_close_popup");	
	
func set_prompt_texture(val):
	PromptTexture = val;
	
	if(PromptTexture != null && has_node("Popup/Panel/PromptFrame")):
		var frame = get_node("Popup/Panel/PromptFrame");
		
		var desiredHeight = 103;
		var desiredWidth = PromptTexture.get_size().x / float(PromptTexture.get_size().y) * desiredHeight;
		
		frame.set_texture(PromptTexture);
		frame.set_size(Vector2(PromptTexture.get_size().x / float(PromptTexture.get_size().y) * desiredHeight, desiredHeight));
		frame.set_margin(MARGIN_LEFT, desiredWidth / 2);
		frame.set_margin(MARGIN_RIGHT,  -desiredWidth / 2);
		
func set_prompt_text(val):
	get_node("Popup/Panel/YesButton").set_prompt(val);
	get_node("Popup/Panel/PromptFrame").Prompt = val;
	pass

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	popup.disconnect("about_to_show", self, "show");
			
	get_node("Popup/Panel/YesButton").disconnect("pressed", self, "_go_to_next_scene");
	get_node("Popup/Panel/NoButton").disconnect("pressed", self, "_close_popup");

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
			
		
func _unhandled_input(event):
	if(event.is_action("ui_cancel") && event.is_pressed()):		
		get_tree().set_input_as_handled();
		_close_popup();
		

func _go_to_next_scene():
	if(NextScene != null):
		get_tree().set_pause(false);
		get_tree().change_scene(NextScene);
	else:
		get_tree().quit();		

func _close_popup():
	if(get_parent() != null):
		emit_signal(CLOSING);
		get_parent().remove_child(self);
	