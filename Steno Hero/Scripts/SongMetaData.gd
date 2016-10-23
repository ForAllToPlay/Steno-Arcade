const util = preload('res://Scripts/Utility.gd');
var TimeStamp = preload("TimeStamp.gd");
var SongData = preload("SongData.gd");
var Word = preload("Word.gd");

var title;
var artist;
var album;
var language;
var length;

var difficulty;
var sourceFile;
var musicFile;
var artFile;
var releaseYear;

func _init(title, artist, album, relyear, language, length, difficulty, sourcefile, musicfile, artfile):
	self.title = title;
	self.artist = artist;
	self.album = album;
	self.language = language;
	self.length = length;
	self.difficulty = difficulty;
	self.sourceFile = sourcefile;
	self.musicFile = musicfile;
	self.artFile = artfile;
	self.releaseYear = relyear;
	
func get_diag_display_string():
	var result = "";
	result += "[Song Meta Data]\n"
	result += "Source File: " + sourceFile + "\n";
	if(title != null):
		result += "Title: " + title + "\n";
	if(artist != null):
		result += "Artist: " + artist + "\n";
	if(album != null):
		result += "Album: " + album + "\n";
	if(artFile != null):
		result += "Art File: " + artFile + "\n";
	if(language != null):
		result += "Language: " + language + "\n";
	if(length != null):
		result += "Length: " + length.get_display_string() + "\n";
	if(difficulty != null):
		result += "Difficulty: " + str(difficulty) + "\n";
	result += "Audio File: " + musicFile;
	
	return result;
	
func get_display_string():
	var result = "";
	
	result += title;
	if(artist):
		result += " by " + artist;
	"""
	if(length):
		result += " - Length: " + length.get_display_string();
			
	if(difficulty):
		result += " - Difficulty: ";
		for i in range(difficulty):
			result += "Ø";
	"""
	return result;
	
func get_difficulty_string():
	if(difficulty == null):
		return "Normal";
		
	if(difficulty <= 1):
		return "Very Easy";
	elif(difficulty == 2):
		return "Easy";
	elif(difficulty == 3):
		return "Normal";
	elif(difficulty == 4):
		return "Hard";
	else:
		return "Very Hard";
	
	
const LINE_START = "[";
const LINE_END = "]";
const WORD_START = "<";
const WORD_END = ">";
const ENDWORD_START = "{";
const ENDWORD_END = "}";

func generate_song():

	var song = SongData.new(self);

	var file = File.new();
	if(!file.file_exists(sourceFile)):
		print("Music metadata file \"" + str(sourceFile) + "\" not found.");
		return null;
	
	var result = file.open(sourceFile, File.READ);	
	
	if(result):	
		print("Cannot open file \"" + str(sourceFile) + "\" Error code: " + str(result));
		return null;

	var displayLyrics = "";
	var line = file.get_line();
	var lineNumber = 0;
	while !file.eof_reached() || !util.is_null_or_whitespace(line):
		lineNumber += 1;
		line = line.strip_edges();
		#If this look like a meta-info line (the entire line is within a "[]"), ignore it.
		if(line.length() <= 2 || (line[0] == LINE_START && line[line.length() - 1] == LINE_END)):		
			#Add a new line for styling if the line was empty.
			if(line.length() == 0 && displayLyrics != ""):
				displayLyrics += '\n';
							
			line = file.get_line();
			continue;
		
		#Now start processing words
		var remainingLine = line;
		while(!util.is_null_or_whitespace(remainingLine)):
			#Find the first "[" (new line) or "<" (new word)
			var firstNewLine = remainingLine.find(LINE_START);			
			var firstNewWord = remainingLine.find(WORD_START);
			
			var openIndex;
			var closingCharacter;
			#If both exist, find the first one
			if(firstNewLine >= 0 && firstNewWord >= 0):
				openIndex = min(firstNewLine, firstNewWord);
				if(openIndex == firstNewWord):
					closingCharacter = WORD_END;
				else:
					closingCharacter = LINE_END;
			#If only the new word exists, pick it out
			elif(firstNewWord >= 0):
				openIndex = firstNewWord;
				closingCharacter = WORD_END;
			#If only the new line exists, pick it out
			elif(firstNewLine >= 0):			
				openIndex = firstNewLine;
				closingCharacter = LINE_END;				
			#If there are no more words or lines in this line, move on to the next line
			else:
				break;
			
			#Now find the closing character
			var closeIndex = remainingLine.find(closingCharacter);
			
			#If the closing character dosn't exist, we have a malformed line. Inform the user and skip this line
			if(closeIndex < 0):
				print("Malformed line (no closing bracket) #" + str(lineNumber) + ": " + line);
				break;
			
			#If the closing character is the last character on the line (with no word following it), we have a malformed line
			if(closeIndex >= remainingLine.length() - 1):				
				print("Malformed line (no word after tag) #" + str(lineNumber) + ": " + line);
				break;
				
			#Pull out the time stamp
			var timeStampStr = remainingLine.substr(openIndex, closeIndex + 1);
			remainingLine = remainingLine.substr(closeIndex + 1, remainingLine.length() - (closeIndex + 1));
			
			var timeStamp = TimeStamp.parse(timeStampStr);
			if(timeStamp == null):
				print("Malformed time stamp, line #" + str(lineNumber) + ": cannot parse time stamp from " + timeStampStr + " in line \"" + line + "\"");
				break;
			
			#If the word we found was using a line timestamp, add a new line marker to the song
			if(closingCharacter == LINE_END && song.word_count() > 0):
				song.add_word(Word.new("\n", timeStamp, null));
				displayLyrics += "\n";
				
			#Now find out where the word ends.
			var endTagIndex = remainingLine.find(ENDWORD_START);
			var actualEndTagIndex = endTagIndex;
			if(endTagIndex < 0):
				endTagIndex = remainingLine.length();
			else:
				pass
				
			var newLineIndex = remainingLine.find(LINE_START);
			if(newLineIndex < 0):
				newLineIndex = remainingLine.length();
				
			var newWordIndex = remainingLine.find(WORD_START);
			if(newWordIndex < 0):
				newWordIndex = remainingLine.length();
			
			var contentCount = min(endTagIndex, min(newLineIndex, newWordIndex));
			var hasEndTag = contentCount == actualEndTagIndex;
			
			#Now pull out that word
			var wordtext = remainingLine.substr(0, contentCount);
			wordtext = wordtext.strip_edges();
			
			if(contentCount == remainingLine.length()):
				remainingLine = "";
			else:
				remainingLine = remainingLine.substr(contentCount, remainingLine.length() - contentCount);
		
			#Now we have a time stamp and a word.. get the end tag, if one exists
			var endTimeStamp = null;
			if(hasEndTag):
				var endTagCloseIndex = remainingLine.find(ENDWORD_END);
				
				#If no close index was specified, then we have a malformed line
				if(endTagCloseIndex < 0):
					print("Malformed end tag time stamp, line #" + str(lineNumber) + ": no end character specified for end word time stamp in line \"" + line + "\"");
					break;
				
				#Pull out the end tag
				var endTimeStampStr = remainingLine.substr(0, endTagCloseIndex + 1);
			
				if(endTagCloseIndex + 1 < remainingLine.length()):
					remainingLine = remainingLine.substr(endTagCloseIndex + 1, remainingLine.length() - (endTagCloseIndex + 1));
				else:
					remainingLine = "";
					
				endTimeStamp = TimeStamp.parse(endTimeStampStr);
				if(endTimeStamp == null):
					print("Malformed end time stamp, line #" + str(lineNumber) + ": cannot parse time stamp from " + endTimeStampStr + " in line \"" + line + "\"");
					break;
					
			#Now construct a word from the given information, if the word found wasn't empty
			if(!util.is_null_or_whitespace(wordtext)):
				if(wordtext.find(" ") >= 0):
					print("WARNING: More than one word was found within a time window: \"" + wordtext + "\". Splitting the word evenly.");
				
				var word = Word.new(wordtext, timeStamp, endTimeStamp);			
				song.add_word(word);
				displayLyrics += wordtext + " ";
			
		line = file.get_line();

	file.close();
	
	#Set the display lyrics to be shown in full to the player.
	song.set_display_lyrics(displayLyrics);
	
	#Now sort all of the words and assign end time stamps
	song.refresh();	
	
	#Clear any in-game properties
	song.clear_in_game_properties();
	
	return song;