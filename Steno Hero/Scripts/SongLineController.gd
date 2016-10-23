
extends Label

var StenoHeroGlobals;
var GameController;
var ScreenRef;

var SongData;
var currentLineIndex;
var currentLine;

var wordTrackerMaterial;
func _is_using_word_tracker():
	return wordTrackerMaterial != null;
const LEFT_COLOR_PARAM = "LeftColor";
const RIGHT_COLOR_PARAM = "RightColor";
const CUTOFF_PARAM = "CutoffPercent";
const GRADIENT_PARAM = "GradientWidth";
	
export (int) var LineOffset = 0;

const LINE_CHANGED = "line_changed";

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	ScreenRef = get_node("/root/StenoHeroGame/ScreenRef");
	
	wordTrackerMaterial = get_material();
	if(_is_using_word_tracker()):
		wordTrackerMaterial.set_shader_param(GRADIENT_PARAM, 0);
		wordTrackerMaterial.set_shader_param(LEFT_COLOR_PARAM, Color(241/255.0, 192/255.0, 38/255.0));		
		wordTrackerMaterial.set_shader_param(RIGHT_COLOR_PARAM, Color(1,1,1));
		wordTrackerMaterial.set_shader_param(CUTOFF_PARAM, 0);
	
	SongData = StenoHeroGlobals.SongData;
	
	add_user_signal(LINE_CHANGED);
	
	_set_current_line(0);
	set_process(true);

func _clear_line():
	if(get_text() != ""):
		set_text("");
	
func _set_current_line(index):
	_clear_line();
	
	currentLineIndex = index;
		
	if(SongData.lines.size() <= currentLineIndex):	
		emit_signal(LINE_CHANGED, null);
		return;
	
	currentLine = SongData.lines[index];
	emit_signal(LINE_CHANGED, currentLine);
	
	var displayIndex = index + LineOffset;
	if(SongData.lines.size() <= displayIndex):
		return;
		
	var displayLine = SongData.lines[displayIndex];	
	if(!displayLine):
		return;
		
	set_text(displayLine.get_display_string());
	set_percent_visible(1);
	
	"""var textSize = get("custom_fonts/font").get_string_size(get_text());
	set_margin(MARGIN_LEFT, textSize.x / 2);
	set_margin(MARGIN_RIGHT, -textSize.x / 2);"""

func _process(delta):
	_update_current_line();
	_update_word_tracker();
	
func _update_current_line():
	if(!currentLine):
		return;
		
	if(GameController.SongTimer > currentLine.end.seconds):
		var nextLineIndex = currentLineIndex + 1;
				
		#If we have no more lines, do nothing
		if(SongData.lines.size() <= nextLineIndex):
			_clear_line();
		#If the line hasn't finished yet (and we are looking at the current line) clear the line
		elif(SongData.lines[nextLineIndex].start.seconds > GameController.SongTimer):
			if(LineOffset == 0):
				_clear_line();
		#Otherwise it is safe to advance
		else:
			_set_current_line(nextLineIndex);
			

func _update_word_tracker():
	if(!_is_using_word_tracker()):
		return;
	
	var Word = GameController.CurrentWord;
	if(!Word || Word.is_lull_word()):	
		wordTrackerMaterial.set_shader_param(CUTOFF_PARAM, 0);
		return;	
	
	#We need to determine what the percentage of the start and end of this word are in screen space..
	
	#So, determine the full line before the start of this word.
	var startText = "";
	
	var prevWord = Word.previous;
	while(prevWord && !prevWord.is_line_break()):
		startText = prevWord.text + " " + startText;
		prevWord = prevWord.previous;
	
	#And the same line plus this word
	var endText = startText + Word.text + " ";
	var lineText = "";
	if(Word.owningLine):
		lineText = Word.owningLine.get_display_string();
	
	var startSize = get("custom_fonts/font").get_string_size(startText);
	var endSize = get("custom_fonts/font").get_string_size(endText);
	var fullSize = get("custom_fonts/font").get_string_size(lineText);
	
	#Find the start of the text in screen space
	var globalRect = get_global_rect();
	var xPos = globalRect.pos.x;
	
	if(get_align() == ALIGN_CENTER):
		xPos += globalRect.size.x / 2 - fullSize.x / 2;
	if(get_align() == ALIGN_RIGHT):
		xPos += globalRect.size.x - fullSize.x;
	
	var wordStartX = xPos + startSize.x;
	var wordEndX = xPos + endSize.x;
		
	#now convert the screenspace into a percentage	
	var screenWidth = ScreenRef.get_size().x;
	var wordStartPercent = wordStartX / screenWidth;	
	var wordEndPercent = wordEndX / screenWidth;
		
	#Now lerp between the start and end percent using the percentage of current time in the word
	var scrollPercent = lerp(wordStartPercent, wordEndPercent, (GameController.SongTimer - Word.start.seconds)/(Word.end.seconds - Word.start.seconds));
	
	wordTrackerMaterial.set_shader_param(CUTOFF_PARAM, scrollPercent);
	