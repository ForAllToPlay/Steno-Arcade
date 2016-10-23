const Line = preload("res://Steno Hero/Scripts/Line.gd");
const Word = preload("res://Steno Hero/Scripts/Word.gd");
const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");

var words setget ,get_words;
var avg_words_per_second setget ,get_wps;
var avg_chars_per_second setget ,get_cps;
var lines setget ,get_lines;
var displayLyrics setget set_display_lyrics, get_display_lyrics;

var _wordDictionary;

var _needsSorting;

var metaData;

func _init(metaData):
	self.metaData = metaData;
	
	words = [];
	_wordDictionary = Dictionary();
	_needsSorting = false;	
	
func add_word(var word):
	words.append(word);
	_needsSorting = true;	
	
func get_words():
	if _needsSorting:
		refresh();
	return words;

func get_wps():
	if _needsSorting:
		refresh();
	return avg_words_per_second;

func get_cps():
	if _needsSorting:
		refresh();
	return avg_chars_per_second;
	
func get_lines():
	if _needsSorting:
		refresh();
	return lines;

func word_count():
	return words.size();
	
func get_first_word():
	if _needsSorting:
		refresh();
	if(words.size() > 0):
		return words[0];
	return null;
func get_last_word():
	if _needsSorting:
		refresh();
	if(words.size() > 0):
		return words[words.size() - 1];
	return null;
	
func get_first_line():
	if _needsSorting:
		refresh();
	if(lines.size() > 0):
		return lines[0];
	return null;
func get_last_line():
	if _needsSorting:
		refresh();
	if(lines.size() > 0):
		return lines[lines.size() - 1];
	return null;
	
func has_word(wordText):
	if _needsSorting:
		refresh();
	return _wordDictionary.has(Word.compute_matchable_string(wordText));
	
func refresh():
	#First ensure that all of the words are in the correct order, based on time
	words.sort_custom(self, "_sort_function");
	
	#Now assign end times to words that don't have any
	_assign_end_stamps();
	
	#Split words that has spaces
	_split_joined_words();
	
	#Assign next and previous links
	_assign_links();
	
	#Now calculate the speed of the words/characters in the song
	_calc_wps();
	
	#Join the words into lines
	_generate_lines();
	
	#Create a dictionary of all of the words
	_construct_word_dictionary();
	
	_needsSorting = false;
	
func _sort_function(a, b):
	if(a.start.seconds == b.start.seconds):
		#Ensure that new lines are first before words that occur at the same time.
		if(a.text == "\n"):
			return true;
		if(b.text == "\n"):
			return false;		
		
	return a.start.seconds < b.start.seconds;
	
func _assign_end_stamps():
	#For every word..
	for i in range(words.size()):
		#Check to make sure the end time doesn't overlap the next word, if so, cap the end time.
		if(i + 1 < words.size() && words[i].end && words[i].end.seconds > words[i + 1].start.seconds):
			words[i].end = words[i+1].start;
	
		#If this word has no end time..
		if(words[i].end == null):
			#If the word isn't the last one,
			if(i + 1 < words.size()):
				#Assign its end time as the start of the next one.
				words[i].end = words[i+1].start;
			else:
				#Otherwise, assign its end time as the end of the song
				words[i].end = metaData.length;

func _split_joined_words():
	var wordCache = words;
	words = [];
	
	for word in wordCache:
		var spaceIndex = word.text.find(" ");
		
		if(spaceIndex >= 0):
			var wordpieces = word.text.split(" ", false);

			var startseconds = word.start.seconds;
			var endseconds = word.end.seconds;
			var step = (endseconds - startseconds) / wordpieces.size();
			
			var currentseconds = startseconds;
			
			for splitword in wordpieces:
				words.append(Word.new(splitword, TimeStamp.new(currentseconds), TimeStamp.new(currentseconds + step)));
				currentseconds = startseconds + step;
		else:
			words.append(word);

func _assign_links():
	if(words.size() <= 0):
		return;
		
	for i in range(words.size() - 1):
		words[i].set_next_word(words[i+1]);
		words[i+1].set_previous_word(words[i]);

func _calc_wps():	
	var wordCount = 0;
	var charCount = 0;
	var seconds = float(0);
	
	for word in words:
		if(word.is_line_break()):
			continue;
		wordCount += 1;
		charCount += word.text.length();
		seconds += word.length.seconds;
	
	if(seconds != float(0)):	
		avg_words_per_second = wordCount / seconds;
		avg_chars_per_second = charCount / seconds;
	else:
		avg_words_per_second = 0;
		avg_chars_per_second = 0;
	
func _generate_lines():
	lines = [];
	
	var currentLine = Line.new();
	
	for word in words:
		if(word.is_line_break()):
			if(!currentLine.is_empty()):
				lines.append(currentLine);
			
			var prevLine = currentLine;
			currentLine = Line.new();
			
			prevLine.set_next_line(currentLine);
			currentLine.set_previous_line(prevLine);
		else:
			currentLine.add_word(word);
			word.owningLine = currentLine;

	if(!currentLine.is_empty()):
		lines.append(currentLine);

func _construct_word_dictionary():
	_wordDictionary = Dictionary();
	
	for word in words:
		var matchText = word.get_matchable_string();
		
		if(!_wordDictionary.has(matchText)):
			_wordDictionary[matchText] = 0;
		_wordDictionary[matchText] += 1;
		
	
func get_diag_display_string():
	var result = "";
	
	for word in words:
		result += word.get_diag_display_string() + "\n";
	
	result += "Average Words/Seconds: " + str(avg_words_per_second) + "\n";
	result += "Average Characters/Seconds: " + str(avg_chars_per_second);
	
	return result;

func get_display_lyrics():
	if(displayLyrics != null):
		return displayLyrics;
		
	var lyrics = "";
	for l in lines:
		if(l != null):
			lyrics += l.get_display_string() + '\n';
			if(l.next != null):
				if(abs(l.end.seconds - l.next.start.seconds) > 1.5):
					lyrics += '\n';
					
	return lyrics;
func set_display_lyrics(val):
	displayLyrics = val;
	
func clear_in_game_properties():
	for word in words:
		word.entered = false;
		word.detectedTime = null;