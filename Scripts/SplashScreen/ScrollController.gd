
extends MarginContainer

const Spring = preload("res://Scripts/Spring.gd");
const DefaultBackground = preload("res://Splash Screen/Sprites/MainBackground.tex");

var ScreenRef;

var TargetX;
var CurrentX;
var TargetSpring;

var FocusedButton;

var BackgroundFocusButton;
var BackgroundHoverButton;

func _ready():
	ScreenRef = get_node("/root/SplashScreen/ScreenRef");

	ScreenRef.connect(ScreenRef.SIZE_CHANGED, self, "_on_screen_resize");
	
	var buttons = get_tree().get_nodes_in_group("GameButtons");
	for b in buttons:
		b.connect(b.FOCUSED, self, "_on_gameButton_focus");
		b.connect(b.RAW_HOVERED, self, "_on_gameButton_focus");
		b.connect(b.HOVERED, self, "_background_gamebutton_hovered");
		b.connect(b.FOCUSED, self, "_background_gamebutton_focused");		
		
	TargetX = float(get_pos().x);
	CurrentX = float(get_pos().x);
	TargetSpring = Spring.new(1, 150, 1);
	
	set_fixed_process(true);
	
func _scroll_to_focus_button():
	if(FocusedButton == null):
		return;
	
	var buttonWidth = FocusedButton.get_size().x;
	var padding = get("custom_constants/margin");
	var minOffset = max(FocusedButton.get_pos().x - buttonWidth / 2, 0);
	var maxOffset = FocusedButton.get_pos().x + buttonWidth + padding * 2 + buttonWidth / 2;
	
	if(minOffset + get_pos().x < 0):
		TargetX = -minOffset;
	
	if(maxOffset + get_pos().x > ScreenRef.get_size().x):	
		TargetX = ScreenRef.get_size().x - maxOffset;
		
func _on_gameButton_focus(button, focused):
	if(focused):
		FocusedButton = button;		
		_scroll_to_focus_button();
		
func _show_background_image(button, show):
	var image = get_node("/root/SplashScreen/ScreenRef/Background/BackgroundImage");
	
	if(image != null):
		if(show):
			if(image.get_texture() != button.BackgroundTexture):
				image.set_texture(button.BackgroundTexture);
				image.refresh_size();
				image.restart_animation();
		else:
			image.set_texture(DefaultBackground);
			image.refresh_size();		
	pass
	
func _background_gamebutton_focused(button, focused):	
	#If a button was just focused..
	if(focused):
		BackgroundFocusButton = button;
		
		#Set the description to match that button
		if(BackgroundFocusButton != null):
			_show_background_image(BackgroundFocusButton, true);
		else:
			_show_background_image(null, false);
	#If a button lost focus, and it was the last focused button..
	elif(button == BackgroundFocusButton):
		#Clear the focus buttons
		BackgroundFocusButton = null;		
		
		#Set the description to match the hovered button, if there is one
		if(BackgroundHoverButton != null):
			_show_background_image(BackgroundHoverButton, true);
		else:
			_show_background_image(null, false);
	pass
func _background_gamebutton_hovered(button, hovered):	
	#If a button was just focused..
	if(hovered):
		BackgroundHoverButton = button;
		
		#Set the description to match that button
		if(BackgroundHoverButton != null):
			_show_background_image(BackgroundHoverButton, true);
		else:
			_show_background_image(null, false);
	#If a button lost focus, and it was the last focused button..
	elif(button == BackgroundHoverButton):
		#Clear the focus buttons
		BackgroundHoverButton = null;		
		
		#Set the description to match the hovered button, if there is one
		if(BackgroundFocusButton != null):
			_show_background_image(BackgroundFocusButton, true);
		else:
			_show_background_image(null, false);
	pass


func _on_screen_resize(size, oldSize):
	_scroll_to_focus_button();

func _fixed_process(delta):
	if(FocusedButton != null && FocusedButton.is_animating()):
		return;
		
	var offset = CurrentX - TargetX;	
	TargetSpring.Fixed_Update(delta, offset);
	
	var posDelta = TargetSpring.Velocity * delta;
	CurrentX += posDelta;
	
	set_pos(Vector2(round(CurrentX), get_pos().y));