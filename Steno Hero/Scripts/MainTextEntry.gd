
extends LineEdit

var PairedDisplayLabel;
var DisplayFont = preload("res://Steno Hero/Fonts/MainLyricsFont.fnt");

func _ready():	
	PairedDisplayLabel = get_node("../CurrentLineLabel");
	PairedDisplayLabel.connect(PairedDisplayLabel.LINE_CHANGED, self, "_on_line_changed");
	_on_line_changed(PairedDisplayLabel.currentLine);
	
	grab_focus();
	connect("focus_exit", self, "_on_mainTextEntry_focus_exit");
	pass

func _on_mainTextEntry_focus_exit():
	grab_focus();
	
	
func _on_line_changed(newLine):
	set_text("");
	
	if(newLine != null):	
		var text = newLine.get_display_string();		
		var dimensions = DisplayFont.get_string_size(text);	
		var windowSize = OS.get_window_size();
		
		var width = dimensions.x / 2 + windowSize.x / 2;
		set_size(Vector2(width, dimensions.y));
		set_pos(Vector2(windowSize.x / 2 - dimensions.x / 2, get_pos().y));
	