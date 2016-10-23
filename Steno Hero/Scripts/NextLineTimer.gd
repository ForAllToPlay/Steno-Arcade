
extends Label

const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");

var StenoHeroGlobals;
var GameController;

var SongData;
var currentLine;

export (int) var LineOffset = 0;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");


	SongData = StenoHeroGlobals.SongData;
	
	currentLine = SongData.get_first_line();
	
	set("custom_fonts/font", StenoHeroGlobals.LyricDisplayFont);	
	var padding = StenoHeroGlobals.get_control_text_padding(StenoHeroGlobals.LyricDisplayFont);
	set_margin(MARGIN_TOP, ceil(padding));
	set_margin(MARGIN_BOTTOM, ceil(padding));
	
	set_process(true);

func _process(delta):
	while(currentLine && GameController.SongTimer >= currentLine.start.seconds):
		currentLine = currentLine.next;
		
	if(currentLine):
		var timeUntilNextLine = TimeStamp.new(currentLine.start.seconds - GameController.SongTimer + GameController.CountdownTimer);
		set_text(timeUntilNextLine.get_display_string(1, timeUntilNextLine.DISPLAY_FORCE_MINUTES));		
	else:
		set_text("");