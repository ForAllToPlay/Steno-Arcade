
extends Control

const SkylinePiece = preload("res://Steno Hero/Prefabs/Skyline.scn");

var ReferencePiece;

var ForegroundPieces;
var Background1Pieces;
var Background2Pieces;

var ForegroundTex = preload("res://Steno Hero/Sprites/InGame/Buildings - Foreground.tex");
var Background1Tex = preload("res://Steno Hero/Sprites/InGame/Buildings - Background 01.tex");
var Background2Tex = preload("res://Steno Hero/Sprites/InGame/Buildings - Background 02.tex");


func _ready():
	var screenRef = get_node("/root/StenoHeroGame/ScreenRef");
	screenRef.connect(screenRef.SIZE_CHANGED, self, "_set_pieces");

	ReferencePiece = SkylinePiece.instance();
	ForegroundPieces = [];
	Background1Pieces = [];
	Background2Pieces = [];
	
	_set_pieces(screenRef.get_size(), screenRef.get_size());
	
func _set_pieces(screenSize, oldSize):
	var width = ReferencePiece.get_margin(MARGIN_RIGHT) - ReferencePiece.get_margin(MARGIN_LEFT);
	var pieces = ceil(screenSize.x / width);
	
	var childCount = ForegroundPieces.size();
	var childrenToRemove = max(childCount - pieces, 0);
	var childrenToAdd = max(pieces - childCount, 0);
	
	for i in range(childrenToRemove):
		_remove_piece(childCount - 1 - i);
		
	for i in range(childrenToAdd):
		_add_piece(width * (childCount + i));

func _remove_piece(index):
		remove_child(ForegroundPieces[index]);
		ForegroundPieces.remove(index);
		
		remove_child(Background1Pieces[index]);
		Background1Pieces.remove(index);
		
		remove_child(Background2Pieces[index]);
		Background2Pieces.remove(index);
	
func _add_piece(xposition):
		var piece = SkylinePiece.instance();		
		add_child(piece);
		
		var position = Vector2(xposition, piece.get_pos().y);
		piece.set_pos(position);
		piece.set_texture(Background2Tex);
		Background2Pieces.append(piece);
		
		piece = SkylinePiece.instance();
		add_child(piece);
		piece.set_pos(position);
		piece.set_texture(Background1Tex);
		Background1Pieces.append(piece);

		piece = SkylinePiece.instance();
		add_child(piece);
		piece.set_pos(position);
		piece.set_texture(ForegroundTex);
		ForegroundPieces.append(piece);


