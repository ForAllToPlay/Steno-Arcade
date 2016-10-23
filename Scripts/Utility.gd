static func getLineEditOffset():
	return 36;
	
static func randfMax(maxVal):
	return randf() * maxVal;
	
static func randfRange(minVal, maxVal):
	return lerp(minVal, maxVal, randf());

static func randiMax(maxVal):
	if(maxVal <= 0):
		return 0;
	return randi() % int(round(maxVal));
	
static func randiRange(val1, val2):
	val1 = int(round(val1));
	val2 = int(round(val2));
	
	if(val1 == val2):
		return val1;
		
	var minVal = min(val1, val2);
	var maxVal = max(val1, val2);	
	return (randi() % (maxVal - minVal)) + minVal;

static func is_null_or_empty(string):
	return string == null || string == "";
	
static func is_null_or_whitespace(string):
	return string == null || string.strip_edges() == "";
	
static func break_string_to_fit(font, text, width, breakInnerWords = true):	
	var lines = text.split('\n');
	var currentLine = "";
	var currentLineSize = Vector2();
	
	for line in lines:		
		var pieces = line.split(' ');
		for word in pieces:
			var wordtoadd = word + ' ';
			var wordSize = font.get_string_size(wordtoadd);
			
			if(currentLineSize.x + wordSize.x >= width):
				if(wordSize.x >= width && breakInnerWords):
					
					for character in range(wordtoadd.length()):
						var chartoadd = word.ord_at(character);
						var charSize = font.get_string_size(character);
						
						if(currentLineSize.x + charSize.x >= width):
							currentLine += '\n' + chartoadd;
							currentLineSize = charSize;
						else:
							currentLine += chartoadd;
							currentLineSize.x += charSize.x;
							
				else:
				
					currentLine += '\n' + wordtoadd;
					currentLineSize = wordSize;
				
			else:
				currentLine += wordtoadd;
				currentLineSize.x += wordSize.x;
				
		currentLine += '\n';
		currentLineSize = Vector2();
	
	#Remove trailing newline
	if(currentLine.length() > 0 && currentLine[currentLine.length() - 1] == "\n"):
		currentLine = currentLine.substr(0, currentLine.length() - 1);	
	
	return currentLine;
	