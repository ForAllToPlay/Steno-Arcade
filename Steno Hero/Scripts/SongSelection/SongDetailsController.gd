
extends PanelContainer

const Util = preload("res://Scripts/Utility.gd");

var header;
var body;

func _ready():
	var parent = get_parent();
	parent.connect(parent.METADATA_CHANGED, self, "_on_metadata_changed");
	parent.connect(parent.METADATA_CLEARED, self, "_on_metadata_cleared");

	header = get_node("VBoxContainer/Header");
	body = get_node("VBoxContainer/Body");

func _on_metadata_changed(metaData):
	if(metaData.title != null):	
		var headerText = Util.break_string_to_fit(header.get("custom_fonts/font"), metaData.title.to_upper(), header.get_size().x);		
		header.set_text(headerText);
	else:
		header.set_text("Untitled");
		
	
	var bodyText = "";
	if(metaData.artist != null):
		bodyText += str(metaData.artist) + "\n";
	
	if(metaData.album != null && metaData.releaseYear != null):
		bodyText += str(metaData.album) + ", " + str(metaData.releaseYear) + "\n";
	elif(metaData.album != null):
		bodyText += str(metaData.album) + "\n";
	elif(metaData.releaseYear != null):
		bodyText += str(metaData.releaseYear) + "\n";
		
	if(metaData.length != null):
		bodyText += metaData.length.get_display_string(0) + "\n";
	
	#Remove trailing newlines
	while(bodyText.length() > 0 && bodyText[bodyText.length() - 1] == "\n"):
		bodyText = bodyText.substr(0, bodyText.length() - 1);
	
	bodyText = Util.break_string_to_fit(body.get("custom_fonts/font"), bodyText, body.get_size().x);		
	
	body.set_text(bodyText);

func _on_metadata_cleared():
	header.set_text("Song Info");
	body.set_text("Hover over a song or use the arrow\nkeys to view song information.");