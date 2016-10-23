
extends Label

#This is how many points a word is worth per the "speed" of the word in characters/second
const BASE_POINT_RATE = float(50 / 1.833);

#This is highest value a word can be worth
const MAX_POINTS_PER_WORD = float(500);


#This is how far from the start of the word the player can be before they get MIN_PERCENT percent of the points for the word
const PRE_DIMINISH_DISTANCE = float(.4);

#This is the percentage of the points for the word the player can get when they are POST_DIMINISH_TIME seconds from the end of the word 
const POST_DIMINISH_PERCENT = float(.33);
#This is how far from the the end of the word the player can be to get POST_DIMINISH_PERCENT percent of the points for the word
const POST_DIMINISH_TIME = float(.25);

#This is the smallest percent of the points of the word the player can get for actually typing a word corretly.
const MIN_PERCENT = float(.1);

var PreDiminishFactor;
var PostDiminishRate;

var accessible;

func _get_pre_diminish_percent(distance):

	if(distance <= 0):
		return 1;
	if(distance >= POST_DIMINISH_TIME):
		return MIN_PERCENT;
		
	distance = float(distance);
		
	var percent = log(PreDiminishFactor * distance + 1 ) + 1;
	percent = clamp(percent, MIN_PERCENT, 1);
	return percent;

func _get_post_diminish_percent(distance):
	if (distance < 0):
		return 1;
		
	var percent = exp(PostDiminishRate * distance);	
	percent = clamp(percent, MIN_PERCENT, 1);
	
	return percent;

var score setget _set_score;

var GameController;
var TextEntry;

func _init():
	PreDiminishFactor = -(1/PRE_DIMINISH_DISTANCE) * ((exp(1) - 1)/exp(1));
	PostDiminishRate = log(POST_DIMINISH_PERCENT)/POST_DIMINISH_TIME;

func _ready():
	accessible = AccessibleFactory.recreate(accessible, self);
	GameController = get_node("/root/StenoHeroGame");
	TextEntry = get_node("../TextInput");

	self.score = 0;
	
	TextEntry.connect(TextEntry.WORD_SUBMIT, self, "_on_word_entered");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func _on_word_entered(word):
	if(!word || !word.is_typeable_word()):
		return;
		
	var time;
	if(word.detectedTime):
		time = word.detectedTime;
	else:
		time = GameController.SongTimer;
	
	var characters = word.text.length();
	var seconds = word.length.seconds;
	
	var points;
	if(seconds != 0):
		points = min(BASE_POINT_RATE * characters / seconds, MAX_POINTS_PER_WORD);
	else:
		points = MAX_POINTS_PER_WORD;
		
					
	if(time >= word.scoreAdjustedStart.seconds && time <= word.scoreAdjustedEnd.seconds):			
		self.score += points;
	#If the player is too late...
	elif(time > word.scoreAdjustedEnd.seconds):
		var distance = (time - word.scoreAdjustedEnd.seconds);
		
		var percent = _get_post_diminish_percent(distance);		
		self.score += round(points * percent);
	#If the player is too soon...
	else:
		var distance = (word.scoreAdjustedStart.seconds - time);
		
		var percent =  _get_pre_diminish_percent(distance);
		self.score += round(points * percent);
	

func _set_score(val):
	score = val;
	_set_text_box();
	
func get_score_string():
	return str(score).pad_decimals(0);
	
func _set_text_box():	
	set_text("Score: " + get_score_string());