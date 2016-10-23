
export(float) var seconds = 0.0;

const SECONDS_PER_MINUTE = 60;
const MINUTES_PER_HOUR = 60;

const DISPLAY_NONE = 0;
const DISPLAY_FORCE_MINUTES = 1;
const DISPLAY_FORCE_HOURS = 2;

func _init(seconds):
	self.seconds = seconds;

static func GET_MINUTES(seconds):
	return seconds / SECONDS_PER_MINUTE;
func get_minutes():
	return GET_MINUTES(seconds);
	
static func GET_FULL_MINUTES(seconds):
	return int(floor(seconds / SECONDS_PER_MINUTE));	
func get_full_minutes():
	return GET_FULL_MINUTES(seconds);
	
static func GET_HOURS(seconds):
	return GET_MINUTES(seconds) / MINUTES_PER_HOUR;	
func get_hours():
	return GET_HOURS(seconds);
	
static func GET_FULL_HOURS(seconds):
	return int(floor(GET_MINUTES(seconds) / MINUTES_PER_HOUR));
func get_full_hours():
	return GET_FULL_HOURS(seconds);

func get_display_string(decimal_places = null, displayMode = DISPLAY_NONE):
	var secondsRemaining = seconds;
	
	var hours = GET_FULL_HOURS(secondsRemaining);
	secondsRemaining -= hours * MINUTES_PER_HOUR * SECONDS_PER_MINUTE;
	
	var minutes = GET_FULL_MINUTES(secondsRemaining);
	secondsRemaining -= minutes * SECONDS_PER_MINUTE;
	
	var forceHours = (displayMode & DISPLAY_FORCE_HOURS) != DISPLAY_NONE;
	var forceMinutes = forceHours || (displayMode & DISPLAY_FORCE_MINUTES) != DISPLAY_NONE;
	
	var result = "";
	if(hours || forceHours):
		result += str(hours) + ":";
	if(minutes || forceMinutes):
		result += str(minutes).pad_zeros(2) + ":";
	
	if(decimal_places != null):
		result += str(secondsRemaining).pad_zeros(2).pad_decimals(decimal_places);
	else:
		result += str(secondsRemaining).pad_zeros(2);
	
	return result;

static func parse(timeStamp):
	if(typeof(timeStamp) != TYPE_STRING):
		return null;
	
	timeStamp = timeStamp.replace("[", "").replace("]","").replace("<","").replace(">","").replace("{","").replace("}","").replace(" ","");	
	var pieces = timeStamp.split(":", false);
	
	var seconds = 0;
	if(pieces.size() == 1):
		seconds = float(pieces[0]);
	elif(pieces.size() == 2):
		var minutes = int(pieces[0]);
		seconds = float(pieces[1]) + minutes * SECONDS_PER_MINUTE;	
	elif(pieces.size() >= 3):
		var hours = int(pieces[pieces.size() - 3]);
		var minutes = int(pieces[pieces.size() - 2]) + hours * MINUTES_PER_HOUR;
		seconds = float(pieces[pieces.size() - 1]) + minutes * SECONDS_PER_MINUTE;	
	
	return new(seconds);

static func add(timeStampA, timeStampB):
	var seconds = 0;
	
	if(timeStampA):
		seconds += timeStampA.seconds;
	if(timeStampB):
		seconds += timeStampB.seconds;
		
	return new(seconds);
	
static func subtract(timeStampA, timeStampB):
	var seconds = 0;
	
	if(timeStampA):
		seconds += timeStampA.seconds;
		
	if(timeStampB):
		seconds -= timeStampB.seconds;
		
	return new(seconds);