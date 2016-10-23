
extends Node2D

const Util = preload("res://Scripts/Utility.gd");
const AnimationCollection = preload("res://Steno Hero/Scripts/Scene/AudienceMemberAnimationCollection.gd");
const AudiencePrePath = "res://Steno Hero/Sprites/InGame/Characters/AudienceMember";
const HappyPath = "/Happy/Happy.res";
const SadPath = "/Sad/Sad.res";
const WalkPath = "/Walk/Walk.res";

static func _generateFrames(audienceNumber):
	return AnimationCollection.new(load(str(AudiencePrePath, audienceNumber, HappyPath)),load(str(AudiencePrePath, audienceNumber, SadPath)),load(str(AudiencePrePath, audienceNumber, WalkPath)));

var AudienceMember1Frames = _generateFrames("1");
var AudienceMember2Frames = _generateFrames("2");
var AudienceMember3Frames = _generateFrames("3");
var AudienceMember4Frames = _generateFrames("4");

#The following are the states an audience member can be in. IDLE, ENTERING, and UNHAPPY, and LEAVING are transitional states
#(the member will automatically switch into a different mode after an event happens).

#This mode is when the member is in the audience, but not dancing, because no music is playing
#When the music starts, the member will switch to HAPPY mode.
const IDLE_MODE = 0;
#This mode is when the member is in the audience and dancing. All is well
const HAPPY_MODE = 1;
#In this mode, the member will walk into place, then enter HAPPY mode.
const ENTERING_MODE = 2;
#In this mode, the member will stop dancing, pause for a moment, then enter LEAVING mode.
const UNHAPPY_MODE = 3;
#In this mode, the member will walk away and leave the stage.
const LEAVING_MODE = 4;
#In this mode, the member will be invisible, but will enter after a delay
const READY_TO_ENTER_MODE = 5;
#In this mode, the member will maintain its action, before turning to the UNHAPPY mode after a delay
const READY_TO_BE_UNHAPPY = 6;

export(float) var FramePercent setget _set_frame_percent; 

var modeAux;
var modeDelay;
var currentMode;

var GameController;
var Body;
var Animator;

var FrameCollection;

func _init():
	set_opacity(0);
	var memberNumber = Util.randiMax(4);
	
	if(memberNumber == 0):
		FrameCollection = AudienceMember1Frames;
	elif(memberNumber == 1):
		FrameCollection = AudienceMember2Frames;
	elif(memberNumber == 2):
		FrameCollection = AudienceMember3Frames;
	elif(memberNumber == 3):
		FrameCollection = AudienceMember4Frames;

func _ready():
	GameController = get_node("/root/StenoHeroGame");
	Animator = get_node("Animator");
	Body = get_node("Body");
	
	Animator.connect("finished", self, "_on_animation_finished");
	
	set_mode(IDLE_MODE, 0);
	set_process(true);
	
func set_mode(mode, delay = 0, aux = 0):
	modeDelay = delay;
	modeAux = aux;
	currentMode = mode;
	
	if(currentMode == IDLE_MODE):	
		Body.set_sprite_frames(FrameCollection.Sad);
		Animator.play("Idle");
	elif(currentMode == HAPPY_MODE):
		Body.set_sprite_frames(FrameCollection.Happy);
		Animator.play("Dancing");
	elif(currentMode == ENTERING_MODE):	
		Body.set_sprite_frames(FrameCollection.Walk);
		Animator.play("Entering");
	elif(currentMode == UNHAPPY_MODE):
		Body.set_sprite_frames(FrameCollection.Sad);
		Animator.play("Idle");
	elif(currentMode == LEAVING_MODE):
		Body.set_sprite_frames(FrameCollection.Walk);
		Animator.play("Leaving");
	elif(currentMode == READY_TO_ENTER_MODE):
		Animator.play("ReadyToEnter");
	
func _set_frame_percent(val):
	FramePercent = val;
	
	var wrappedPercent = fmod(FramePercent, 1);
	if(Body == null):
		return;
	
	var Frames = Body.get_sprite_frames();
	if(Frames == null):
		return;
		
	var currentFrame = lerp(0, Frames.get_frame_count(), wrappedPercent);
	currentFrame = min(int(floor(currentFrame)), Frames.get_frame_count() - 1);
	
	Body.set_frame(currentFrame);
	
	var texture = Frames.get_frame(currentFrame);
	if(texture == null):
		return;
		
	Body.set_offset(Vector2(0, -texture.get_height() / 2));
	
	
func _process(delta):
	if(currentMode == IDLE_MODE):
		if(GameController.Started):
			modeDelay -= delta;
			if(modeDelay <= 0):
				set_mode(HAPPY_MODE);
	elif(currentMode == UNHAPPY_MODE):
		modeDelay -= delta;
		if(modeDelay <= 0):
			set_mode(LEAVING_MODE);
	elif(currentMode == READY_TO_ENTER_MODE):
		modeDelay -= delta;
		if(modeDelay <= 0):
			set_mode(ENTERING_MODE);
	elif(currentMode == READY_TO_BE_UNHAPPY):
		modeDelay -= delta;
		if(modeDelay <= 0):
			set_mode(UNHAPPY_MODE, modeAux);

func _on_animation_finished():
	var animation  = Animator.get_current_animation();
	
	if(animation == "Entering"):
		set_mode(HAPPY_MODE);
	if(animation == "Leaving"):
		queue_free();
		