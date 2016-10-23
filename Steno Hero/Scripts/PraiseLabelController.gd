
extends Label

var StenoHeroGlobals;
var GameController;

var velocity;
var acceleration;

var targetPosition = Vector2(0,0);

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	
	var animationPlayer = get_node("AnimationPlayer");
	
	var font = StenoHeroGlobals.LyricDisplayFont;
	set("custom_fonts/font", font);	
	
	var height = font.get_string_size(" ABCDEFGHIJKLMNOPQRSTUVWXYZ").y;
	
	var riseHeight = -height * 1;
	var riseTime = animationPlayer.get_animation("Fade").get_length();
	
	velocity = float(riseHeight * 2) / riseTime;
	acceleration = float(-velocity) / riseTime;
	
	animationPlayer.connect("finished", self, "_on_animation_finished");
	set_fixed_process(true);
	
	_position_element();
	
func set_prompt(text, position, scale):
	set_text(text);
	get_material().set_shader_param("Scale", scale);
	targetPosition = position;
	_position_element();
	
func _position_element():
	if(targetPosition == null):
		return;

	var font = get("custom_fonts/font");
	
	if(!font):
		return;
		
	var text = get_text();
	var textSize = font.get_string_size(text) * get_material().get_shader_param("Scale");
	
	var spawnPosition = Vector2(targetPosition.x - textSize.x / 2, targetPosition.y - textSize.y);
	set_pos(spawnPosition);
	pass

func _fixed_process(delta):
	velocity += acceleration * delta;	
	var positionDelta = velocity * delta;
	
	var pos = get_global_pos();
	set_global_pos(Vector2(pos.x, pos.y + positionDelta));
	
func _on_animation_finished():
	queue_free();