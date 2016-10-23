extends Node

const GameInfo = preload('res://Scripts/GameInfo.gd');
const LyricDisplayFont = preload('res://Steno Hero/Fonts/LyricDisplay.fnt');
var LyricLeaveAcceleration;

var SongData;

func _init():
	var CharSize = LyricDisplayFont.get_string_size(" ");
	
	#Gain X spaces/second/second when leaving
	LyricLeaveAcceleration = 10 * CharSize.x;

func start_song(songMetaData, SceneFadeOut):
	get_node("/root/BackgroundMusic").stop();

	self.SongData = null;
	
	if(songMetaData):
		self.SongData = songMetaData.generate_song();
	
	if(SongData):
		if(SceneFadeOut):
			SceneFadeOut.EndScene(GameInfo.StenoHeroGameScene, 1);
		else:	
			get_tree().change_scene(GameInfo.StenoHeroGameScene);

	
static func _get_test_string():
	return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 ";		
static func _get_control_text_padding_percent():
	return .33;
	
static func get_control_text_padding(font):
	var testString = _get_test_string();
	var textHeight = font.get_string_size(testString).y;
	var padding = textHeight * _get_control_text_padding_percent();
	
	return padding;
	
static func get_control_height_from_font(font):
	var testString = _get_test_string();	
	var textHeight = font.get_string_size(testString).y;
	var padding = textHeight * _get_control_text_padding_percent();
	
	var controlHeight = textHeight + padding * 2;	
	return controlHeight;
	
static func align_text_control_to_bottom(control, font, row_from_bottom):
	var controlHeight = get_control_height_from_font(font);
	
	control.set_anchor_and_margin(MARGIN_LEFT, control.ANCHOR_BEGIN, 0);
	control.set_anchor_and_margin(MARGIN_RIGHT, control.ANCHOR_END, 0);
	
	control.set_anchor_and_margin(MARGIN_TOP, control.ANCHOR_END, controlHeight * (row_from_bottom + 1));
	control.set_anchor_and_margin(MARGIN_BOTTOM, control.ANCHOR_END, controlHeight * row_from_bottom);
	