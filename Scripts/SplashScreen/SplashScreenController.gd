
extends Node2D


func _ready():		
	var music = get_node("/root/BackgroundMusic");
	music.play_default_music();

	#Give input focus to the first enabled game.
	var buttons = get_tree().get_nodes_in_group("GameButtons");
	for b in buttons:
		if(!b.is_disabled()):
			b.grab_focus();
			break;
	pass
