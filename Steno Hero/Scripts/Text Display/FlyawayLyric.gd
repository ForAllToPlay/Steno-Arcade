
extends RichTextLabel

const util = preload("res://Scripts/Utility.gd");

var StenoHeroGlobals;

var Animator;

var currentVelocity;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	Animator = get_node("AnimationPlayer");
	
	currentVelocity = 0;
	
	set_process(true);
	
func copy(rtLabel, text):
	set("custom_fonts/normal_font", rtLabel.get("custom_fonts/normal_font"));
	set_selection_enabled(false);
	set_bbcode(rtLabel.get_bbcode());
	
	var textSize = get("custom_fonts/normal_font").get_string_size(text);	

	set_anchor_and_margin(MARGIN_TOP, rtLabel.get_anchor(MARGIN_TOP), rtLabel.get_margin(MARGIN_TOP));
	set_anchor_and_margin(MARGIN_BOTTOM, rtLabel.get_anchor(MARGIN_BOTTOM), rtLabel.get_margin(MARGIN_BOTTOM));
	
	set_size(Vector2(rtLabel.get_size().x, rtLabel.get_size().y));
	set_pos(Vector2(rtLabel.get_pos().x, rtLabel.get_pos().y));
	
	currentVelocity = 0;

func _process(delta):	
	if(Animator.get_current_animation() != "FadeOut"):
		Animator.play("FadeOut");
		
	currentVelocity -= delta * StenoHeroGlobals.LyricLeaveAcceleration;	
	var offsetDelta = currentVelocity * delta;
	
	var currentPos = get_pos();
	currentPos.x += offsetDelta;
	set_pos(currentPos);
		
	if(currentPos.x < -get_size().x):
		queue_free();