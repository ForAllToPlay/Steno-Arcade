
extends Label

var maxStreak = 0;
var streak setget _set_streak;
var softStreak setget _set_soft_streak;

var GameController;
var TextEntry;

var accessible;

func get_streak():
	return streak;
func get_max_streak():
	return maxStreak;
func get_soft_streak():
	return softStreak;

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	
	GameController = get_node("/root/StenoHeroGame");
	TextEntry = get_node("../TextInput");

	self.streak = 0;
	self.softStreak = 0;
	
	GameController.connect(GameController.LINE_FINISHED, self, "_on_line_finished");
	#GameController.connect(GameController.WORD_FINISHED, self, "_on_word_finished");
	#TextEntry.connect(TextEntry.WORD_REALTIME, self, "_on_word_entered");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
	
func _on_line_finished(line):
	#Recalculate the streak based on the finalized line
	for word in line.words:	
		if(!word || !word.is_typeable_word()):
			return;
		
		var time;
		if(word.detectedTime):
			time = word.detectedTime;
			
			if(time >= word.scoreAdjustedStart.seconds && time <= word.scoreAdjustedEnd.seconds):	
				self.streak += 1;
			else:
				self.streak = 0;		
		else:
			self.streak = 0;
			
		self.softStreak = streak;

func _on_word_finished(word):
	
	#Detect if a word was missed
	if(!word || !word.is_typeable_word()):
		return;
	
	if(!word.detectedTime):
		self.softStreak = 0;
		return;
		
	if(word.detectedTime < word.scoreAdjustedStart.seconds || word.detectedTime > word.scoreAdjustedEnd.seconds):	
		self.softStreak = 0;
		
func _on_word_entered(word):
	if(!word || !word.is_typeable_word()):
		return;
	#Detect if a word was entered correctly
	if(word.detectedTime >= word.scoreAdjustedStart.seconds && word.detectedTime <= word.scoreAdjustedEnd.seconds):	
		self.softStreak += 1;
	else:
		self.softStreak = 0;
		

func _set_streak(val):
	maxStreak = max(maxStreak, val);
	streak = val;
	
func _set_soft_streak(val):
	softStreak = val;
	_set_text_box();
	
func get_streak_string(streak):	
	var wordText = "words";
	
	if(streak == 1):
		wordText = "word";
		
	return str(streak) + " " + wordText;

func _set_text_box():	
	set_text("Streak: " + get_streak_string(softStreak));