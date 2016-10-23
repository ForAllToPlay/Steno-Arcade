
extends CenterContainer

var UnavailableArt = preload("res://Steno Hero/Sprites/SongSelect/AlbumArtUnavailable.tex");

var Frame;

var maxWidth;
var maxHeight;

func _ready():
	var parent = get_parent();
	parent.connect(parent.METADATA_CHANGED, self, "_on_metadata_changed");
	parent.connect(parent.METADATA_CLEARED, self, "_on_metadata_cleared");

	Frame = get_node("AlbumArt");
	
	maxWidth = get_size().x;
	maxHeight = maxWidth * 1.5;
	
	
func _on_metadata_changed(metaData):
	var albumArtTex;
	
	if(metaData != null && metaData.artFile != null):		
		albumArtTex = load(metaData.artFile);
	else:
		albumArtTex = UnavailableArt;
		
	if(albumArtTex != null):	
		albumArtTex.fix_alpha_edges();	
		
		var ratio = albumArtTex.get_height() / float(albumArtTex.get_width());
		var height = maxWidth * ratio;
		var width = maxWidth;
		if(height > maxHeight):
			height = maxHeight;
			width = height / ratio;
			
		Frame.set_texture(albumArtTex);
		Frame.set_custom_minimum_size(Vector2(width, height));
		Frame.set_size(Vector2(width, height));
	
	pass
	
func _on_metadata_cleared():
	Frame.set_texture(null);
	pass