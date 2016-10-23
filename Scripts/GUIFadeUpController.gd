
extends AnimationPlayer

export(bool) var Enabled = true;
export(float) var WaitTime;
export(float) var FadeTime;

func _ready():	
	
	connect("finished", self, "_on_animation_finished");
	
	if(Enabled):
		
		get_parent().set_opacity(0);
		
		if(!!WaitTime && WaitTime > 0):
			play("Wait", -1, get_animation("Wait").get_length() / WaitTime);	
		elif(!!FadeTime && FadeTime > 0):
			play("FadeUp", -1, get_animation("FadeUp").get_length() / FadeTime);	
	else:
	
		get_parent().set_opacity(1);
	pass
	
func _on_animation_finished():
	if(get_current_animation() == "Wait" &&  !!FadeTime && FadeTime > 0):
		play("FadeUp", -1, get_animation("FadeUp").get_length() / FadeTime);
		
func play_fade():
	if(FadeTime > 0):
		get_parent().set_opacity(0);		
		play("FadeUp", -1, get_animation("FadeUp").get_length() / FadeTime);	
