
extends ReferenceFrame

const SIZE_CHANGED = "REFERENCE_SIZE_CHANGED";

var DefaultResolution;

func _init():
	DefaultResolution = Vector2(Globals.get("display/width"), Globals.get("display/height"));
	add_user_signal(SIZE_CHANGED);

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_size_changed");
	
	_on_size_changed();	
	
func _on_size_changed():
	var oldSize = get_size();
	
	var rect = get_tree().get_root().get_rect();	
	
	var ar = float(rect.size.x) / rect.size.y;
	set_size(Vector2(ar * DefaultResolution.y, DefaultResolution.y));	
	set_pos(Vector2(0,0));
	
	emit_signal(SIZE_CHANGED, get_size(), oldSize);



