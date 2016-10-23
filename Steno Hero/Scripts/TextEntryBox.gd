
extends LineEdit

func _ready():
	grab_focus();
	connect("focus_exit", self, "_on_entrybox_focus_exit");
	pass

func _on_entrybox_focus_exit():
	grab_focus();