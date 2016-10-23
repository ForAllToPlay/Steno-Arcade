
extends TextureFrame

const FADE_IN_SIGNAL = "faded_in";
const FADE_OUT_SIGNAL = "faded_out";

export(bool) var FadeInScene = false;
export(float) var FadeInDuration = 1;

var nextScene;
var animationPlayer;

var EndingScene;

func _ready():
	
	add_user_signal(FADE_IN_SIGNAL);
	add_user_signal(FADE_OUT_SIGNAL);

	EndingScene = false;
	nextScene = null;
	animationPlayer = get_node("AnimationPlayer");
	animationPlayer.connect("finished", self, "on_animationPlayer_finished");
	
	if(FadeInScene):
		StartScene(FadeInDuration);

func StartScene(FadeInDuration = 1):
	set_modulate(Color(0, 0, 0, 1));
	animationPlayer.play("Blackin", -1, 1 / max(FadeInDuration, .01) );

func EndScene(NextScene, FadeOutDuration = 1):
	if(nextScene || !NextScene):
		return;
		
	EndingScene = true;
	self.nextScene = NextScene;
	animationPlayer.play("Blackout", -1, 1 / max(FadeOutDuration, .01) );
	
func on_animationPlayer_finished():

	if(animationPlayer.get_current_animation() == "Blackout"):
		emit_signal(FADE_OUT_SIGNAL);
	elif(animationPlayer.get_current_animation() == "Blackin"):
		emit_signal(FADE_IN_SIGNAL);
		
		
	if(animationPlayer.get_current_animation() != "Blackout"):
		return;
		
	EndingScene = false;
		
	if(!nextScene):
		set_modulate(Color(0,0,0,0));
		return;
	
	var type = typeof(nextScene);
	if(type == TYPE_STRING):
		get_tree().change_scene(nextScene);
	else:
		get_tree().change_scene_to(nextScene);
	