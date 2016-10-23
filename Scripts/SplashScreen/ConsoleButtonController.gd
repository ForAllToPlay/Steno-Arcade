extends TextureButton

const GameInfo = preload('res://Scripts/GameInfo.gd');

export(String, "None", "Steno Hero") var nextScene;

var animator;
var buttonController;

func _ready():
	# Initialization here
	animator = get_node("Animator");
	buttonController = get_node("../ButtonController");
	
	connect("focus_enter", self, "on_ConsoleButton_focus_enter");
	connect("focus_exit", self, "on_ConsoleButton_focus_exit");
	connect("mouse_enter", self, "on_ConsoleButton_mouse_enter");
	connect("mouse_exit", self, "on_ConsoleButton_mouse_exit");
	connect("pressed", self, "on_ConsoleButton_pressed");
	

func triggerFadeUp(otherStatesEnabled):	
	if(otherStatesEnabled):
		return;
		
	if animator:
		animator.play("FadeUp");
	else:
		set_modulate(Color(1,1,1,1));
		
func triggerFadeDown(otherStatesEnabled):	
	if(otherStatesEnabled):
		return;
		
	if animator:
		animator.play("FadeDown");
	else:
		set_modulate(Color(1,1,1,0));	
		

func on_ConsoleButton_focus_enter():
	triggerFadeUp(is_hovered());
	

func on_ConsoleButton_focus_exit():
	triggerFadeDown(is_hovered());

func on_ConsoleButton_mouse_enter():
	triggerFadeUp(has_focus());
	
func on_ConsoleButton_mouse_exit():
	triggerFadeDown(has_focus());

func on_ConsoleButton_pressed():
	if(buttonController):
		var sceneName = GameInfo.GetScene(nextScene);
		if(sceneName):
			buttonController.end_scene(sceneName);
	return;
	