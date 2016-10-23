
extends Panel

const TYPE = "LyricLine";
const LINE_BREAK_WIDTH = 2;

const MIN_PRAISE_SCALE = .85;
const MAX_PRAISE_SCALE = 1.25;
const PRAISE_STEPS = 3;

const util = preload("res://Scripts/Utility.gd");
const PraiseLabel = preload("res://Steno Hero/Prefabs/PraiseLabel.scn");

var StenoHeroGlobals;
var GameController;
var TextEntry;
var StreakTracker;

var Line;

var PreviousLineControl;

var InterlinePadding;
var EmptyPixelsPerSecond;

var currentVelocity;

var LyricLabel;
var Animator;
var LineBreak;

func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");
	TextEntry = GameController.get_node("ScreenRef/TextInput");
	StreakTracker = GameController.get_node("ScreenRef/Streak");
	
	LyricLabel = get_node("Label");
	Animator = get_node("AnimationPlayer");
	LineBreak = get_node("LineBreak");
	LineBreak.set_margin(MARGIN_LEFT, LINE_BREAK_WIDTH);
		
	var CharSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(" ");
	EmptyPixelsPerSecond = CharSize.x * StenoHeroGlobals.SongData.avg_chars_per_second;
	
	InterlinePadding = CharSize.x * 4;
	
	set_line(Line);
	
	LyricLabel.set_margin(MARGIN_LEFT, InterlinePadding);
	
	
	currentVelocity = 0;
	
	set_margin(MARGIN_TOP, 0);
	set_margin(MARGIN_BOTTOM, 0);	
	
	_set_previous_line(get_parent());	
	_set_distance(0);
	set_process(true);

func set_line(line):
	Line = line;
	if(line && LyricLabel):
		LyricLabel.set_text(line.get_display_string());
		var textSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(LyricLabel.get_text());
		set_custom_minimum_size(Vector2(textSize.x + InterlinePadding * 2 + LINE_BREAK_WIDTH, textSize.y));
	
func _process(delta):
	_update_parent();
	_set_distance(delta);
	
func _set_previous_line(previousLine):
	var parent = previousLine;
	if(parent != null && parent.get("TYPE") == TYPE):
		PreviousLineControl = parent;
		if(TextEntry.is_connected(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime")):
			TextEntry.disconnect(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime");
	else:
		PreviousLineControl = null;
		if(!TextEntry.is_connected(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime")):
			TextEntry.connect(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime");
		
	
func _update_parent():
	if(PreviousLineControl != null && GameController.SongTimer >= PreviousLineControl.Line.end.seconds):
		var superParent = PreviousLineControl.get_parent();
		PreviousLineControl.remove_child(self);
		superParent.add_child(self);
		_set_previous_line(superParent);
		
	
func _set_distance(delta):
	if(GameController.SongTimer - GameController.CountdownTimer < Line.start.seconds):
		_set_preline_position(delta);
	elif (GameController.SongTimer - GameController.CountdownTimer <= Line.end.seconds):
		_set_line_position(delta);
	else:
		_set_postline_position(delta);
		
	
func set_left_position(anchor, offset, timeDelta):	
	set_anchor(MARGIN_LEFT, anchor);
	
	var lastMargin = get_margin(MARGIN_LEFT);
	var currentMargin = offset;
	
	set_margin(MARGIN_LEFT, currentMargin);
	
	if(timeDelta != 0):
		currentVelocity = -abs(currentMargin - lastMargin) / timeDelta;
	
func _set_preline_position(delta):	
	
	if(PreviousLineControl != null):
		#If there is a line before it, determine how many seconds between the lines
		var timeBetweenLines = Line.start.seconds - PreviousLineControl.Line.end.seconds;
		
		#Turn these seconds into a pixel offset
		var offset = timeBetweenLines * EmptyPixelsPerSecond;
		
		set_left_position(ANCHOR_END, -offset, delta);
	else:
		#If there are no lines before this, determine how many seconds before this line starts
		var timeUntilLine = Line.start.seconds - GameController.SongTimer + GameController.CountdownTimer;
		#Turn these seconds into a pixel offset
		var offset = timeUntilLine * EmptyPixelsPerSecond;		
		
		#Set the position		
		set_left_position(ANCHOR_CENTER, -offset, delta);
	
	
func _get_line_position():	
	var Word = GameController.CurrentWord;
	if(!Word):	
		return 0;
	if(Word.owningLine != Line):
		return 1;
		
	
	#So, determine the full line before the start of this word.
	var startText = "";
	
	var isFirstWord = true;
	
	var prevWord = Word.previous;
	while(prevWord && !prevWord.is_line_break()):
		isFirstWord = false;
		startText = prevWord.text + " " + startText;
		prevWord = prevWord.previous;
		
	var isLastWord = Word.next == null || Word.next.is_line_break();	
	
	#And the same line plus this word
	var endText = startText + Word.text;
	if(!isLastWord):
		endText += " ";
	
	var lineText = GameController.CurrentLine.get_display_string();
	
	var startSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(startText);
	if(!isFirstWord):
		startSize.x += InterlinePadding;
	
	var endSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(endText);	
	endSize.x += InterlinePadding;
	if(isLastWord):
		endSize.x += InterlinePadding + LINE_BREAK_WIDTH;
	
	var fullSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(lineText);
	fullSize.x += LINE_BREAK_WIDTH + InterlinePadding * 2;
	
	#Now lerp between the start and end percent using the percentage of current time in the word
	var wordStartPercent = float(startSize.x) / fullSize.x;
	var wordEndPercent = float(endSize.x) / fullSize.x;
	
	var scrollPercent = lerp(wordStartPercent, wordEndPercent, (GameController.SongTimer - Word.start.seconds)/(Word.end.seconds - Word.start.seconds));
	
	return scrollPercent * fullSize.x;

func _set_line_position(delta):
	var xPos = _get_line_position();
	set_left_position(ANCHOR_CENTER, xPos, delta);
	
func _set_postline_position(delta):
	if(Animator.get_current_animation() != "FadeOut"):
		Animator.play("FadeOut");
		
	LineBreak.set_opacity(0);

	currentVelocity -= delta * StenoHeroGlobals.LyricLeaveAcceleration;
	
	var offsetDelta = currentVelocity * delta;
	
	set_anchor(MARGIN_LEFT, ANCHOR_BEGIN);
	
	var lastMargin = get_margin(MARGIN_LEFT);
	var currentMargin = lastMargin + offsetDelta;
	
	set_margin(MARGIN_LEFT, currentMargin);
	
	var textSize = StenoHeroGlobals.LyricDisplayFont.get_string_size(LyricLabel.get_text());
	
	if(currentMargin < -textSize.x):	
		if(TextEntry.is_connected(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime")):
			TextEntry.disconnect(TextEntry.WORD_REALTIME, self, "_on_word_entered_realtime");
		queue_free();

func _on_word_entered_realtime(word):
	return;
	
	if(word.owningLine != Line):
		return;
		
	var parent = get_parent();
	if(!parent):
		return;
		
	var promptText = "";
	if(GameController.SongTimer >= word.scoreAdjustedStart.seconds && GameController.SongTimer <= word.scoreAdjustedEnd.seconds):
		promptText = "Great!";
	else:
		promptText = "Good";
		
	#Measure the entire line up until that word
	var lineText = "";
	for w in word.owningLine.words:
		if(w == word):
			break;
		lineText += w.text + " ";
		
	var font = LyricLabel.get("custom_fonts/font");
	
	var lineSize = font.get_string_size(lineText);
	var wordSize = font.get_string_size(word.text);
	
	var startOffset = lineSize.x + wordSize.x / 2;
	var curPos = get_pos();
	
	var scale = lerp(MIN_PRAISE_SCALE, MAX_PRAISE_SCALE, clamp(float(StreakTracker.get_soft_streak()) / PRAISE_STEPS, 0, 1));
	
	var label = PraiseLabel.instance();
	label.set_prompt(promptText, Vector2(curPos.x + startOffset, curPos.y), scale);
	get_parent().add_child(label);
	 
	