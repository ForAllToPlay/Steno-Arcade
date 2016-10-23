
extends AnimatedSprite

var GameController;

func _ready():
	GameController = get_node("/root/StenoHeroGame");
	
	GameController.connect(GameController.GAME_START, self, '_on_start');
	
	pass
	
func _on_start():
	var animator = get_node("AnimationPlayer");
	animator.play("Play");


