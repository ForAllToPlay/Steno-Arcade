
extends Panel

const util = preload("res://Scripts/Utility.gd");

const WORD_ENTERED = "word_entered";

var StenoHeroGlobals;
var GameController;

var Text;
var FinishedLabel;
var MissedLabel;

var FittingLine;

var TextFont = preload("res://Steno Hero/Fonts/MainLyricsFont.fnt");

func _init():
	add_user_signal(WORD_ENTERED);
	
func _ready():
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	GameController = get_node("/root/StenoHeroGame");	
	GameController.connect(GameController.GAME_START, self, "_start_game");
		
	Text = get_node("Text");
	FinishedLabel = get_node("FinishedLabel");
	MissedLabel = get_node("MissedLabel");
	
	Text.set("custom_fonts/font", TextFont);
	FinishedLabel.set("custom_fonts/font", TextFont);
	MissedLabel.set("custom_fonts/font", TextFont);
	
	_restart_line(StenoHeroGlobals.SongData.get_first_line());
	
	set_process(true);

func _start_game():
	Text.set_editable(true);

func _restart_line(line):
	FittingLine = line;
	
	FinishedLabel.set_text("");
	Text.set_text("");
	MissedLabel.set_text("");
	
	if(!FittingLine):
		return;
	
	var fitLineDimensions = TextFont.get_string_size(FittingLine.get_display_string());
	
	var lineStart = get_size().x / 2 - fitLineDimensions.x / 2;
	
	Text.set_margin(MARGIN_LEFT, lineStart);
	FinishedLabel.set_margin(MARGIN_RIGHT, lineStart);	
	MissedLabel.set_margin(MARGIN_RIGHT, lineStart);	
		
func _process(delta):
	#Process words in the line until we can't anymore
	while(_processInput()):
		pass
	
func _processInput():
	#Break the input into strings
	var words = Text.get_text().split(" ", true);
	
	#Now process every word
	var lineSoFar = "";
	var first = true;
	for word in words:	
		if(!first):
			lineSoFar += " ";
		first = false;
		lineSoFar += word;
		
		#If this word isn't in the song, don't process it
		if(util.is_null_or_whitespace(word) || !StenoHeroGlobals.SongData.has_word(word)):
			continue;
			
		#Find this word in the song
		var wordToMark = _findWord(word);
		if(!wordToMark):
			continue;
			
		wordToMark.entered = true;
		
		var remainingLine = Text.get_text().substr(lineSoFar.length(), Text.get_text().length() - lineSoFar.length());
		
		#TODO: so far behind word wrap around?
		var cursorOffset = Text.get_text().length() - Text.get_cursor_pos();
		#If the next word is a new line..
		if(wordToMark.next && wordToMark.next.is_line_break()):
			
			_restart_line(wordToMark.owningLine.next);
			Text.set_text(remainingLine);
			Text.set_cursor_pos(max(0, Text.get_text().length() - cursorOffset));
		#If the word we've found isn't on the same line...
		elif(wordToMark.owningLine != FittingLine):
			#First restart that on that line
			_restart_line(wordToMark.owningLine);
			
			#Now get all of the line that was skipped
			var skippedLine = "";
			for word in FittingLine.words:
				if(word == wordToMark):
					break;
				skippedLine += word.text + " ";
			
			MissedLabel.set_text(skippedLine);
			#Shift the margin on the missed line to cover the skipped line
			var skippedDimensions = TextFont.get_string_size(skippedLine);
			var missedMargin = MissedLabel.get_margin(MARGIN_RIGHT) + skippedDimensions.x;
			MissedLabel.set_margin(MARGIN_RIGHT, missedMargin);
			
			var successWord = wordToMark.text;
			if(remainingLine.length() > 0 && remainingLine[0] != " "):
				successWord += " ";
			
			FinishedLabel.set_text(successWord);
			var successDimensions = TextFont.get_string_size(successWord);
			var finishedMargin = missedMargin + successDimensions.x;
			FinishedLabel.set_margin(MARGIN_RIGHT, finishedMargin);
			Text.set_margin(MARGIN_LEFT, finishedMargin);
			Text.set_text(remainingLine);			
			Text.set_cursor_pos(max(0, Text.get_text().length() - cursorOffset));
			pass
		else:			
		#Otherwise..
			#Now add the line up to this point to the label and remove it from the textbox
			FinishedLabel.set_text(FinishedLabel.get_text() + lineSoFar);
			Text.set_text(remainingLine);
			Text.set_cursor_pos(max(0, Text.get_text().length() - cursorOffset));
			
			#TODO: What if the text is longer than the box?
			#Now resize the label and textbox
			var offset = TextFont.get_string_size(lineSoFar);
			var newMiddle = Text.get_margin(MARGIN_LEFT) + offset.x;
			Text.set_margin(MARGIN_LEFT, newMiddle);
			FinishedLabel.set_margin(MARGIN_RIGHT, newMiddle);
			
			
		emit_signal(WORD_ENTERED, wordToMark);
		#Return true, we found some matching text..
		return true;
	
	#Return false, we can stop processing
	return false;
	
func _processWord(word):
	if(!word):
		return;
	#If this word isn't in the song, don't process it
	if(!StenoHeroGlobals.SongData.has_word(word)):
		return;
		
	#Find this word in the song
	var wordToMark = _findWord(word);
	if(!wordToMark):
		return;
		
	wordToMark.entered = true;
	print(wordToMark.text);
		

func _findWord(word):
	if(!GameController.CurrentWord || util.is_null_or_whitespace(word)):
		return null;
		
	if(GameController.CurrentWord.text == word && !GameController.CurrentWord.entered):
		return GameController.CurrentWord;
	
	var closestPastWord = null;
	var closestFutureWord = null;
	
	#Look at all of the words previously played
	var currentWordIterator = GameController.CurrentWord.previous;
	while(currentWordIterator && !currentWordIterator.entered):
		if(currentWordIterator.text == word):
			closestPastWord = currentWordIterator;
			break;
		currentWordIterator = currentWordIterator.previous;
		
	#Now look at all of the future words
	currentWordIterator = GameController.CurrentWord;
	while(currentWordIterator):
		if(currentWordIterator.is_line_break()):		
			currentWordIterator = currentWordIterator.next;
			continue;
		if(currentWordIterator.text == word):
			closestFutureWord = currentWordIterator;
			break;
		if(!currentWordIterator.entered):
			break;
		currentWordIterator = currentWordIterator.next;
	
	#If there is a word in the past and future that works, pick the closest one
	if(closestFutureWord && closestPastWord):
		var pastDistance = GameController.SongTimer - closestPastWord.end.seconds;
		var futureDistance = closestFutureWord.start.seconds - GameController.SongTimer;
		
		var closestDistance = min(pastDistance, futureDistance);
		
		if(closestDistance == pastDistance):
			return closestPastWord;
		else:
			return closestFutureWord;
			
		return null;
	#If there is a word in the past that matches, use it
	elif(closestPastWord):
		return closestPastWord;
	#If there is a word in the future that matches, use it
	elif(closestFutureWord):
		return closestFutureWord;		
	#If no words in either direction was found, no dice
	else:
		return null; 
	