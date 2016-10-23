var words;
var start;
var end;

var previous;
var next;

const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");

func _init():
	self.words = [];
	start = null;
	end = null;
	previous = null;
	next = null;

func is_lull_line():
	return words.size() <= 0;

func add_word(word):
	words.append(word);
	
	if(word.start && (start == null || word.start.seconds < start.seconds) ):
		start = word.start;
	if(word.end && (end == null || word.end.seconds > end.seconds) ):
		end = word.end;
		
func set_previous_line(line):
	previous = line;
	
func set_next_line(line):
	next = line;
	
func is_empty():
	return words.size() <= 0;
	
func get_display_string():
	var result = "";
	
	for word in words:
		if(result != ""):
			result += " ";
		result += word.text;
		
	return result;
	