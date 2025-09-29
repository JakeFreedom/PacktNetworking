extends Control
@onready var label: Label = $ScrollContainer/Label
@onready var container: ScrollContainer = $ScrollContainer
@onready var line_edit: LineEdit = $LineEdit

var avatarName: String

func _ready() -> void:
	line_edit.text_submitted.connect(LineEditTextSubmitted)

@rpc("any_peer","call_local","reliable",2)
func add_message(_avatar_name, message)-> void:
	var message_text = "%s: %s" % [_avatar_name, message]
	label.text += "\n" + message_text
	container.scroll_vertical = label.size.y
	
	
func LineEditTextSubmitted(newText: String) -> void:
	if newText.length() == 0:
		return
		
	rpc("add_message", avatarName, newText)
	line_edit.clear()
	pass

@rpc
func SetAvatarName(name) -> void:
	print("Set Avatar Name" + name)
	pass
