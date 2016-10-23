
extends Label

var StenoHeroGlobals;
var GameController;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	
	set("custom_fonts/font", StenoHeroGlobals.LyricDisplayFont);		
	
	var padding = StenoHeroGlobals.get_control_text_padding(StenoHeroGlobals.LyricDisplayFont);
	set_margin(MARGIN_TOP, ceil(padding));
	set_margin(MARGIN_BOTTOM, ceil(padding));
