
extends PanelContainer

export(int) var difficulty = 0 setget _set_dif;

var accessible;

var veryEasyLabel = preload("res://Steno Hero/Sprites/SongSelect/DifficultyLabel_VeryEasy.tex");
var easyLabel = preload("res://Steno Hero/Sprites/SongSelect/DifficultyLabel_Easy.tex");
var normalLabel = preload("res://Steno Hero/Sprites/SongSelect/DifficultyLabels_Normal.tex");
var hardLabel = preload("res://Steno Hero/Sprites/SongSelect/DifficultyLabels_Hard.tex");
var veryHardLabel = preload("res://Steno Hero/Sprites/SongSelect/DifficultyLabels_VeryHard.tex");

var texFrame;
func _ready():
	texFrame = get_node("PanelContainer/CenterContainer/TextureFrame");
	
	self.difficulty = difficulty;
	pass
	
func _set_dif(val):
	difficulty = val;
	
	if(texFrame == null):
		return;
	if(val<= 1):
		texFrame.set_texture(veryEasyLabel);
		accessible.set_name("Very Easy");
	elif(val<= 2):
		texFrame.set_texture(easyLabel);
		accessible.set_name("Easy");
	elif(val<= 3):
		texFrame.set_texture(normalLabel);
		accessible.set_name("Normal");
	elif(val<= 4):
		texFrame.set_texture(hardLabel);
		accessible.set_name("Hard");
	else:
		texFrame.set_texture(veryHardLabel);
		accessible.set_name("Very Hard");

func _enter_tree():
	accessible = AccessibleFactory.recreate(accessible, self);
	
func _exit_tree():
	accessible = AccessibleFactory.clear(accessible);
