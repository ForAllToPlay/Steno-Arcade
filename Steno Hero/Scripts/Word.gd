var text;
var start setget _set_start;
var end setget _set_end;
var length setget _set_len;

var scoreAdjustedStart setget _noop;
var scoreAdjustedEnd setget _noop;

var previous;
var next;

var owningLine;

#This should be true when the player successfully enters this word
var entered;
#This is the time that the game detected that the player has entered the word
var detectedTime;

const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");
const PRE_WORD_FLEX = .5;
const POST_WORD_FLEX = .35;

func _init(text, start, end):
	self.text = text;
	self.start = start;
	self.end = end;
	self.entered = false;
	self.detectedTime = null;
	
static func compute_matchable_string(text):
	if(!text):
		return "";
	return text.strip_edges().to_lower();

func get_matchable_string():
	return compute_matchable_string(text);	
	
func is_line_break():
	return text == "\n";
func is_lull_word():
	return text == "";
func is_typeable_word():
	return !is_line_break() && !is_lull_word();
	
func get_diag_display_string():
	var result = "<";
	if(is_line_break()):
		result += "\\n";
	else:
		result += str(text);
		
	if(start):
		result += " - start: " + start.get_display_string();
	if(end):
		result += " - end: " + end.get_display_string();
	result += ">";
	return result;
	
func _set_start(val):
	start = val;
	_calc_length();
	
	scoreAdjustedStart = null;
	if(start != null):
		scoreAdjustedStart = TimeStamp.new(start.seconds - PRE_WORD_FLEX);
	
func _set_end(val):
	end = val;
	_calc_length();
	
	scoreAdjustedEnd = null;
	if(end != null):
		scoreAdjustedEnd = TimeStamp.new(end.seconds + POST_WORD_FLEX);
	
func _calc_length():
	if(end):
		length = TimeStamp.subtract(end, start);
	else:
		length = 0;
		
	
func _set_len(val):
	length = val;
	end = TimeStamp.add(start, length);

func set_previous_word(word):
	previous = word;
	
func set_next_word(word):
	next = word;
	
func _noop(val):
	pass