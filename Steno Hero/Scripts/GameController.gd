
extends Node2D

const WORD_STARTED = "WORD_STARTED";
const WORD_FINISHED = "WORD_FINISHED";

const LINE_STARTED = "LINE_STARTED";
const LINE_FINISHED = "LINE_FINISHED";

const MAX_OFF_SYNC = .1;

const END_GAME_WAIT = 1.5;

const Word = preload("res://Steno Hero/Scripts/Word.gd");
const Line = preload("res://Steno Hero/Scripts/Line.gd");
const TimeStamp = preload("res://Steno Hero/Scripts/TimeStamp.gd");
const GameInfo = preload("res://Scripts/GameInfo.gd");
const ResultsPopup = preload("res://Steno Hero/Prefabs/ResultsPopup/ResultsPopup.scn");

var resultsPopup;

const GAME_START = "game_start";

var StenoHeroGlobals;
var SceneFadeOut;

var musicPlayer;
var Started;
var Finished;

var CurrentLine = null setget _set_noop;
var CurrentWord = null setget _set_noop;

var CountdownTimer = 0 setget _set_noop;
var SongTimer = 0 setget _set_noop;

var streamOffset = 0;

func _set_noop():
	pass

func _init():
	add_user_signal(GAME_START);
	add_user_signal(WORD_STARTED);
	add_user_signal(WORD_FINISHED);
	add_user_signal(LINE_STARTED);
	add_user_signal(LINE_FINISHED);

func _ready():
	
	StenoHeroGlobals = get_node("/root/StenoHeroGlobals");
	musicPlayer = get_node("MusicPlayer");
	
	SceneFadeOut = get_node("ScreenRef/SceneFadeOut");	
	SceneFadeOut.connect(SceneFadeOut.FADE_IN_SIGNAL, self, "_start_countdown");
	
	musicPlayer.stop();
	musicPlayer.set_stream(load(StenoHeroGlobals.SongData.metaData.musicFile));
		
	Started = false;
	Finished = false;
	CurrentLine = null;
	CurrentWord = null;
	SongTimer = 0;
	
	var countdown = get_node("ScreenRef/StartTimer/AnimationPlayer");
	CountdownTimer = SceneFadeOut.FadeInDuration + countdown.get_animation("Countdown").get_length();
	
	set_process(true);

func _start_countdown():	
	var countdown = get_node("ScreenRef/StartTimer/AnimationPlayer");
	countdown.connect("finished", self, "_start_game");
	countdown.play("Countdown");

func _start_game():
	musicPlayer.play();
	streamOffset = musicPlayer.get_pos();
	
	Started = true;
	SongTimer = 0;
	CountdownTimer = 0;
	
	CurrentWord = StenoHeroGlobals.SongData.get_first_word();
	if(CurrentWord != null && CurrentWord.start.seconds > 0):	
		var lullWord = Word.new("", TimeStamp.new(0), CurrentWord.start);
		lullWord.previous = null;
		lullWord.next = CurrentWord;
		lullWord.entered = true;
		lullWord.owningLine = CurrentWord.owningLine;
		
		CurrentWord = lullWord;
	
	CurrentLine = StenoHeroGlobals.SongData.get_first_line();	
	if(CurrentLine != null && CurrentLine.start.seconds > 0):
		var lullLine = Line.new();
		lullLine.start = TimeStamp.new(0);
		lullLine.end = CurrentLine.start;
		lullLine.set_previous_line(null);
		lullLine.set_next_line(CurrentLine);
		
		CurrentLine = lullLine;
	
	emit_signal(GAME_START);
	emit_signal(LINE_STARTED, CurrentLine);
	emit_signal(WORD_STARTED, CurrentWord);
	
func _process(delta):
	if(!Started):
		CountdownTimer -= delta;
		return;
	
	if(!Finished):
		SongTimer += delta;
		_sync_timer();
	
	_update_word();
	_update_line();
		
	if(!Finished):
		if(SongTimer > StenoHeroGlobals.SongData.metaData.length.seconds + END_GAME_WAIT):
			Finished = true;
			_show_results();
		

func _sync_timer():
	var songPos = musicPlayer.get_pos() - streamOffset;
	if(songPos > SongTimer && (songPos - SongTimer) > MAX_OFF_SYNC):
		SongTimer = songPos;

func _create_lull_word(CurrentWord):
	var lullWord = Word.new("", CurrentWord.end, CurrentWord.next.start);
	lullWord.previous = CurrentWord;
	lullWord.next = CurrentWord.next;
	lullWord.entered = true;
	lullWord.owningLine = CurrentWord.owningLine;
	
	return lullWord;
	
func _update_word():
	if(!Started):
		return;
	
	while(CurrentWord &&  SongTimer >= CurrentWord.end.seconds):	
		emit_signal(WORD_FINISHED, CurrentWord);
		
		if(CurrentWord.next != null):
			if(SongTimer >= CurrentWord.next.start.seconds):
				CurrentWord = CurrentWord.next;			
			else:
				CurrentWord = _create_lull_word(CurrentWord);
				
			emit_signal(WORD_STARTED, CurrentWord);
		else:
			CurrentWord = null;

func _create_lull_line(CurrentLine):
	var lullLine = Line.new();
	lullLine.start = CurrentLine.end;
	lullLine.end = CurrentLine.next.start;
	lullLine.set_previous_line(CurrentLine);
	lullLine.set_next_line(CurrentLine.next);
	
	return lullLine;

func _update_line():
	if(!Started):
		return;
	
	while(CurrentLine && SongTimer >= CurrentLine.end.seconds):	
		emit_signal(LINE_FINISHED, CurrentLine);
		
		if(CurrentLine.next != null):
			if(SongTimer >= CurrentLine.next.start.seconds):
				CurrentLine = CurrentLine.next;
			else:
				CurrentLine = _create_lull_line(CurrentLine);
				
			emit_signal(LINE_STARTED, CurrentLine);
		else:
			CurrentLine = null;
			
func _show_results():
	if(resultsPopup != null):
		return;
		
	resultsPopup = ResultsPopup.instance();

	resultsPopup.set_score(get_node("ScreenRef/MainScore").get_score_string());
	resultsPopup.set_streak(get_node("ScreenRef/Streak").get_streak_string(get_node("ScreenRef/Streak").maxStreak));
	resultsPopup.set_accuracy(get_node("ScreenRef/Accuracy").get_accuracy_string());
	resultsPopup.set_precision(get_node("ScreenRef/Precision").get_precision_string());
	
	add_child(resultsPopup);
	resultsPopup.popup();