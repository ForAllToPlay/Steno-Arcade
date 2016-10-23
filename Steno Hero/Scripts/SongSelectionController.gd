
extends VBoxContainer

const SongMetaDataProvider = preload('res://Steno Hero/Scripts/SongMetaDataProvider.gd');
const SongButton = preload('res://Steno Hero/Prefabs/SongButton/SongButton.scn');
const DifficultyLabel = preload('res://Steno Hero/Prefabs/DifficultyLabel/DifficultyLabel.scn');
var StenoHeroGlobals;

var metaData;

func _ready():
	StenoHeroGlobals = get_node('/root/StenoHeroGlobals');
	
	metaData = SongMetaDataProvider.fetch_all_meta_data_in_directory('res://Steno Hero/Songs');
	
	var lastDifficulty = null;
	
	for i in range(metaData.size()):
		var datum = metaData[i];		
		var extraPadding = 0;
		
		if(lastDifficulty == null || lastDifficulty != datum.difficulty):
			lastDifficulty = datum.difficulty;
			
			if(lastDifficulty != null):
				var labelInstance = DifficultyLabel.instance();
				labelInstance.difficulty = datum.difficulty;
				add_child(labelInstance);
				#HACK: Magic number 62 -- labelInstance.get_size().y not returning the right size?
				extraPadding = 62;
		
		var buttonInstance = SongButton.instance();
		buttonInstance.SongMetaData = datum;
		buttonInstance.ExtraPadding = extraPadding;
		buttonInstance.connect("focus_enter", self, "_on_songButton_focus", [buttonInstance]);
		add_child(buttonInstance);
		
		if(i == 0):
			buttonInstance.grab_focus();
		
func _on_songButton_pressed(metaData):
	StenoHeroGlobals.start_song(metaData, get_node('/root/StenoHeroSongSelect/SceneFadeOut'));
	
func _on_songButton_focus(button):
	var scrollContainer = get_parent();
	if(scrollContainer == null):
		return;		
	scrollContainer = scrollContainer.get_parent();
	if(scrollContainer == null):
		return;	
		
	scrollContainer.set_v_scroll(min(scrollContainer.get_v_scroll(), button.get_pos().y - button.ExtraPadding));
	scrollContainer.set_v_scroll(max(scrollContainer.get_v_scroll(), button.get_pos().y - scrollContainer.get_size().y + button.get_size().y));
