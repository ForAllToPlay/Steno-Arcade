
extends Panel

const util = preload("res://Scripts/Utility.gd");
const LyricLine = preload("res://Steno Hero/Prefabs/LyricLine.scn");

var StenoHeroGlobals;
var GameController;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	
	StenoHeroGlobals.align_text_control_to_bottom(self, StenoHeroGlobals.LyricDisplayFont, 0);
	
	_construct_lines();
	
func _construct_lines():
	
	var lastParent = self;
	
	for line in StenoHeroGlobals.SongData.lines:
		var lyric = LyricLine.instance();
		lyric.set_line(line);
		
		lastParent.add_child(lyric);
		lastParent = lyric;
	
