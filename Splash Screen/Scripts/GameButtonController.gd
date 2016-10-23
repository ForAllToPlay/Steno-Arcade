
extends TextureButton

export(String) var BBCodeTitle;
export(String) var BBCodeDescription;
export(PackedScene) var NextScene setget _set_scene;
export(int) var HorizontalOffset setget _set_h_offset;
export(Texture) var BackgroundTexture;

const HOVERED = "gameButton_hovered";
const RAW_HOVERED = "gameButton_raw_hovered";
const FOCUSED = "gameButton_focus";

var accessible;

var animator;
var defaultPosition;

var lastHovered;
var lastRawHovered;
var lastFocused;

func _enter_tree():
	accessible = AccessibleFactory.recreate_with_name(accessible, self, BBCodeTitle);
func _exit_tree():	
	accessible = AccessibleFactory.clear(accessible);

func _init():	
	add_user_signal(HOVERED);
	add_user_signal(RAW_HOVERED);
	add_user_signal(FOCUSED);
	
func _ready():
	connect("pressed", self, "_go_to_scene");	
	
	animator = get_node("Animator");
	
	set_opacity(0);
	
	var WaitTime = get_index() * .1 + .33;	
	animator.play("Wait", -1, animator.get_animation("Wait").get_length() / WaitTime);
	animator.queue("Start");
	
	defaultPosition = get_pos();
	
	lastHovered = false;
	lastFocused = false;
	
	set_process(true);
	
func _go_to_scene():
	if(NextScene):
		var faders = get_tree().get_nodes_in_group("SceneFaders");
		if(faders.size() > 0):		
			faders[0].EndScene(NextScene, .5);
		else:
			get_tree().change_scene_to(NextScene);
		pass
	pass

func _set_scene(val):
	NextScene = val;
	set_disabled(!val);

func _set_h_offset(val):
	HorizontalOffset = val;
	
	if(defaultPosition != null):
		set_pos(Vector2(defaultPosition.x + HorizontalOffset, defaultPosition.y));
		
func _process(delta):
	_update_state_signals();
	
func is_animating():
	return animator == null || animator.is_playing();

func _update_state_signals():
	var hovered = !is_disabled() && is_hovered();
	if(hovered != lastHovered):
		lastHovered = hovered;
		emit_signal(HOVERED, self, lastHovered);
		
	var rawhovered = is_hovered();
	if(rawhovered != lastRawHovered):
		lastRawHovered = rawhovered;
		emit_signal(RAW_HOVERED, self, lastRawHovered);
		
	var focused = !is_disabled() && has_focus();
	if(focused != lastFocused):
		lastFocused = focused;
		emit_signal(FOCUSED, self, lastFocused);
		
func get_display_description():
	var result = "";
	if(BBCodeTitle != null):
		result += "[b]" + BBCodeTitle + "[/b]";
		
	if(is_disabled()):
		result += "[b](COMING SOON)[/b]";
	
	if(BBCodeDescription != null):
		if(result.length() > 0):
			result += ": ";
		result += BBCodeDescription;
		
	return result;
	
	
func get_accessible_description():
	var result = "";
	if(BBCodeTitle != null):
		result += BBCodeTitle;
		
	if(is_disabled()):
		result += " COMING SOON";
	
	if(BBCodeDescription != null):
		if(result.length() > 0):
			result += ": ";
		result += BBCodeDescription;
		
	return result;