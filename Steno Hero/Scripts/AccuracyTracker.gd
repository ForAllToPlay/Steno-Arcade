
extends Label

var sungWords setget _set_sung_words;
var typedWords setget _set_typed_words;

var GameController;
var TextEntry;

var accessible;

func _ready():	
	accessible = AccessibleFactory.recreate(accessible, self);
	GameController = get_node("/root/StenoHeroGame");
	TextEntry = get_node("../TextInput");

	self.sungWords = 0;
	self.typedWords = 0;
	
	GameController.connect(GameController.LINE_FINISHED, self, "_on_line_finished");
	TextEntry.connect(TextEntry.WORD_SUBMIT, self, "_on_word_entered");

func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);

func _on_line_finished(line):
	for word in line.words:
		if(word && word.is_typeable_word()):
			self.sungWords += 1;
	
func _on_word_started(word):
	if(!word || !word.is_typeable_word()):
		return;
	self.sungWords += 1;
	
func _on_word_entered(word):
	if(!word || !word.is_typeable_word()):
		return;
	self.typedWords += 1;
	

func _set_sung_words(val):
	sungWords = val;
	_set_text_box();
	
func _set_typed_words(val):
	typedWords = val;
	_set_text_box();
	
func get_accuracy_string():	
	var accuracy;
	if(sungWords <= 0):
		accuracy = 1;
	else:
		accuracy = float(typedWords) / float(sungWords);

	var accuracyStr = str(accuracy * 100).pad_decimals(2) + "%";
	return accuracyStr;
	
func _set_text_box():	
	set_text("Accuracy: " + get_accuracy_string());