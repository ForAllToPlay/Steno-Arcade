
extends TextureFrame

const util = preload("res://Scripts/Utility.gd");

var StenoHeroGlobals;
var GameController;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	
	var controlHeight = StenoHeroGlobals.get_control_height_from_font(StenoHeroGlobals.LyricDisplayFont);	
	set_margin(MARGIN_TOP, controlHeight * 2);

	pass


