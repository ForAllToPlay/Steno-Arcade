
extends Label

const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");

var accessible;

var GameController;

var currentTimeStamp;

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	GameController = get_node("/root/StenoHeroGame");
	
	currentTimeStamp = TimeStamp.new(0);
	
	set_process(true);
	
func _process(delta):
	currentTimeStamp.seconds = GameController.SongTimer;
	set_text(currentTimeStamp.get_display_string(2, TimeStamp.DISPLAY_FORCE_MINUTES));
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
