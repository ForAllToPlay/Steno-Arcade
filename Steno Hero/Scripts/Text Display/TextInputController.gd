
extends Panel

const WORD_REALTIME = "WORD_RECOGNIZED_REALTIME";
const WORD_SUBMIT = "WORD_SUBMIT_FOR_GRADING";

const MIN_PRAISE_SCALE = .85;
const MAX_PRAISE_SCALE = 1.25;
const PRAISE_STEPS = 3;

const util = preload("res://Scripts/Utility.gd");
const Word = preload("res://Steno Hero/Scripts/Word.gd");

const FlyawayLyric = preload("res://Steno Hero/Prefabs/FlyawayLyric.scn");
const PraiseLabel = preload("res://Steno Hero/Prefabs/PraiseLabel.scn");

var StenoHeroGlobals;
var GameController;
var ScoreTracker;
var StreakTracker;

var InputBox;
var InputDisplay;
var InputSplitter;

var ActiveLine = null;

var wordMatchCache = [];

export(Color) var RightColor;
export(Color) var WrongColor;
export(Color) var NeutralColor;

var accessible;

func _init():
	add_user_signal(WORD_REALTIME);
	add_user_signal(WORD_SUBMIT);
	
func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	ScoreTracker = get_node("../MainScore");
	StreakTracker = get_node("../Streak");
	
	InputSplitter = get_node("../InputSplitter");
	
	InputBox = get_node("MainInputBox");
	InputBox.set("custom_fonts/font", StenoHeroGlobals.LyricDisplayFont);
	InputBox.grab_focus();
	InputBox.connect("focus_exit", self, "_on_entrybox_focus_exit");
	accessible = AccessibleFactory.recreate_with_name(accessible, InputBox, "Lyrics Input");
	
	InputDisplay = get_node("InputDisplayLabel");
	InputDisplay.set("custom_fonts/normal_font", StenoHeroGlobals.LyricDisplayFont);
	InputDisplay.set_selection_enabled(false);
	InputBox.connect("text_changed", self, "_on_entrybox_text_changed");
	connect(WORD_REALTIME, self, "_show_word_feedback_message");
	
	StenoHeroGlobals.align_text_control_to_bottom(self, StenoHeroGlobals.LyricDisplayFont, 1);
	
	var padding = StenoHeroGlobals.get_control_text_padding(StenoHeroGlobals.LyricDisplayFont);
	InputBox.set_margin(MARGIN_TOP, ceil(padding));
	InputBox.set_margin(MARGIN_BOTTOM, ceil(padding));
	InputDisplay.set_margin(MARGIN_TOP, ceil(padding));
	
	InputBox.connect("text_changed", self, "_set_entrybox_size");
	_clear_input();
	InputBox.set_editable(false);
	
	GameController.connect(GameController.LINE_STARTED, self, "_on_line_started");
	GameController.connect(GameController.LINE_FINISHED, self, "_on_line_ended");
	
	set_process(true);

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func _on_entrybox_focus_exit():
	pass
	
func _set_entrybox_size(text):
	text = InputBox.get_text();
	var font = InputBox.get("custom_fonts/font");
	var textSize = font.get_string_size(text);
	
	var splitterHalfWidth = InputSplitter.get_margin(MARGIN_LEFT);
	
	var controllerHalfWidth = get_size().x / 2;
	
	var leftSide = ceil(textSize.x) + splitterHalfWidth;
	var rightSide = -util.getLineEditOffset() + splitterHalfWidth;
	
	InputBox.set_margin(MARGIN_LEFT, leftSide);	
	InputBox.set_margin(MARGIN_RIGHT, rightSide);
	
	#Shift the cursor to 0 and back to ensure that the box scrolls the text correctly 
	#(when copy-pasting, the box can get shifted over if the entered text is too long)
	var cursor = InputBox.get_cursor_pos();
	InputBox.set_cursor_pos(0);
	InputBox.set_cursor_pos(cursor);
	
func _on_line_started(line):
	ActiveLine = line;
	if(line && !line.is_lull_line()):
		InputBox.set_editable(true);
	
func _on_line_ended(line):
	if(line.is_lull_line()):
		return;
		
	_grade_line(line, InputBox.get_text(), WORD_SUBMIT);

	var lyric = FlyawayLyric.instance();
	InputBox.get_parent().add_child(lyric);
	lyric.copy(InputDisplay, InputBox.get_text());
	
	_clear_input();
	InputBox.set_editable(false);

func _clear_input():
	InputBox.clear();
	InputDisplay.set_bbcode("");
	_set_entrybox_size("");
	
func _process(delta):
	_enforce_focus();
	_allow_pre_entry();
	_grade_line(GameController.CurrentLine, InputBox.get_text(), null, WORD_REALTIME);

func _enforce_focus():
	if(!has_focus() && !get_tree().is_paused() && !GameController.Finished):
		InputBox.grab_focus();
	
func _allow_pre_entry():
	#If the current line is a lull line, and we are X seconds away from ending it.. allow the player to enter text
	if(ActiveLine && ActiveLine.is_lull_line() && (ActiveLine.end.seconds - GameController.SongTimer) <= ScoreTracker.PRE_DIMINISH_DISTANCE && !InputBox.is_editable()):
		InputBox.set_editable(true);

#Looks at a line and some text, and matches up which words have been entered.
#If a matching word is found, "signal" is fired. 
#If a word has already had a match, a signal will be fired, but the "detectedTime"
#will be the first (earliest) time this word has been matched.
func _grade_line(line, text, sig = null, firstSignal = null):		
	if(!line || line.is_lull_line()):
		return;
	
	wordMatchCache.clear();
	
	#Break the input into words
	var inputWords = text.split(" ", true);
	
	#Now try to process the current line
	var EarliestUnmatchedWord = line.words[0];
	
	#For every word the player has made..
	for inputWord in inputWords:
		#Look at all of the words in the line that haven't been matched yet
		var matchedWord = null;
		var currentLineWord = EarliestUnmatchedWord;
		while(currentLineWord && !currentLineWord.is_line_break() && currentLineWord.owningLine == line):
			if(currentLineWord.get_matchable_string() == Word.compute_matchable_string(inputWord)):
				matchedWord = currentLineWord;
				break;
			currentLineWord = currentLineWord.next;
			
		wordMatchCache.append(matchedWord);
		
		#If we've matched a word...
		if(matchedWord):
			#Flag the word so we know that we've now, if we haven't already
			if(!matchedWord.detectedTime):
				matchedWord.detectedTime = GameController.SongTimer;					
				
				if(firstSignal):
					emit_signal(firstSignal, matchedWord);
			
			#And for the rest of this line, only look for words after this word (so the player can't enter words out of order)
			EarliestUnmatchedWord = matchedWord.next;
			
			if(sig != null):
				emit_signal(sig, matchedWord);
				
func _on_entrybox_text_changed(text):	
	var font = InputDisplay.get("custom_fonts/normal_font");
	var textSize = font.get_string_size(text);
	
	InputDisplay.set_margin(MARGIN_LEFT, textSize.x);	
	
	var bbcode = "";
	
	InputDisplay.clear();
	var pieces = text.split(" ", true);
	var index = 0;
	for piece in pieces:
		if(index != 0):
			bbcode += " ";
		if(index < pieces.size() - 1 && index < wordMatchCache.size()):
			if(wordMatchCache[index] != null):
				bbcode += "[color=#" + RightColor.to_html() + "]";
			else:
				bbcode += "[color=#" + WrongColor.to_html() + "]";
		else:
			bbcode += "[color=#" + NeutralColor.to_html() + "]";
		
		bbcode += piece;
		
		bbcode += "[/color]";
		
		index += 1;
		
	InputDisplay.set_bbcode(bbcode);
	
func _show_word_feedback_message(word):
	
	#Determine the praise
	var promptText = "";
	if(GameController.SongTimer >= word.scoreAdjustedStart.seconds && GameController.SongTimer <= word.scoreAdjustedEnd.seconds):
		promptText = "Great!";
	else:
		promptText = "Good";
	
	#Determine the scale of the praise
	var scale = lerp(MIN_PRAISE_SCALE, MAX_PRAISE_SCALE, clamp(float(StreakTracker.get_soft_streak()) / PRAISE_STEPS, 0, 1));
	
	#First measure the entire typed string	
	var font = InputDisplay.get("custom_fonts/normal_font");
	var textSize = font.get_string_size(InputBox.get_text());
	
	#Now find the word in the text that matches the line-word, and construct all of the text that comes before it
	var pieces = InputBox.get_text().split(" ", true);
	var preString = "";
	var index = 0;
	for piece in pieces:
		if(index != 0):
			preString += " ";
			
		preString += piece;
		if(index < wordMatchCache.size() && wordMatchCache[index] == word):			
			break;
			
		index += 1;	
	
	#Measure the entire line up until that word
	var preStringSize = font.get_string_size(preString);
	
	var startOffset = preStringSize;
	var curPos = InputDisplay.get_pos();
		
	var label = PraiseLabel.instance();
	label.set_prompt(promptText, Vector2(curPos.x + startOffset.x, curPos.y), scale);
	
	add_child(label); 