
extends Node

# member variables here, example:
# var a=2
# var b="textvar"
var buttons;
var selectedIndex;

var nextScene;
var sceneFaders;
const sceneEndAnimation = "AlphaUp";

func _ready():
	# Get all of the console buttons
	buttons = get_tree().get_nodes_in_group("ConsoleButton");
	sceneFaders = get_tree().get_nodes_in_group("SceneFadeAnimator");
	
	for fader in sceneFaders:
		fader.connect("finished", self, "on_fader_animator_finished", [fader]);
	
	selectedIndex = -1;
	if buttons.size() > 0:
		selectedIndex = buttons.size() / 2;
		for i in range(buttons.size()):
			if (i == selectedIndex):
				buttons[i].grab_focus();
			else:
				buttons[i].release_focus();
	
	set_process_input(true);
	pass

func advanceButton():
	var selectedIndex = -1;
	for i in range(buttons.size()):
		if(buttons[i].has_focus()):
			buttons[i].release_focus();
			selectedIndex = i;
			
	selectedIndex += 1;
	if selectedIndex >= buttons.size():
		selectedIndex -= floor(float(selectedIndex) / buttons.size()) * buttons.size();
		
	if buttons.size() > selectedIndex && selectedIndex >= 0:
		buttons[selectedIndex].grab_focus();


func previousButton():	
	var selectedIndex = -1;
	for i in range(buttons.size()):
		if(buttons[i].has_focus()):
			buttons[i].release_focus();
			selectedIndex = i;
			
	selectedIndex -= 1;
	if selectedIndex < 0 && buttons.size() > 0:
		selectedIndex += (ceil(abs(float(selectedIndex)) / buttons.size()))* buttons.size();
		
	if buttons.size() > selectedIndex && selectedIndex >= 0:
		buttons[selectedIndex].grab_focus();

func _input(event):
	if event.is_pressed():
		if event.is_action("ui_left") || event.is_action("ui_down") :
			previousButton();
		if event.is_action("ui_right") || event.is_action("ui_up") :
			advanceButton();

func end_scene(nextScene):
	self.nextScene = nextScene;
	for button in buttons:
		button.set_disabled(true);
	
	for animator in sceneFaders:
		animator.play(sceneEndAnimation);
	return;
	
func on_fader_animator_finished(sender):
	if(sender.get_current_animation() == sceneEndAnimation && nextScene != null):
		get_tree().change_scene(nextScene);
	return;
	
