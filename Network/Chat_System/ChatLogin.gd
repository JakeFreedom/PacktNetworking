extends Control
@onready var login: Button = $Login
@onready var user_line_edit: LineEdit = $UserLineEdit
@onready var password_line_edit: LineEdit = $PasswordLineEdit
@onready var error_label: Label = $ErrorLabel

@export var lobbyScene: PackedScene

var peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	login.pressed.connect(OnLoginPressed)
	peer.create_client("localhost", 3000)
	multiplayer.multiplayer_peer = peer
	error_label.text = ""
	
	
func OnLoginPressed() -> void:
	SendCredentials()
	pass
	
func SendCredentials() -> void:
	var user = user_line_edit.text
	var password = password_line_edit.text
	
	rpc_id(get_multiplayer_authority(), "authenticate_player", user, password)
	
@rpc
func AddAvatar()->void:
	pass
	
@rpc
func ClearAvatar() -> void:
	pass
	
@rpc
func RetreiveAvatar(user, sessionToken)-> void:
	pass

@rpc
func authenticate_player(user,password)-> void:
	pass

@rpc
func authentication_failed(message) -> void:
	error_label.text = ""
	error_label.text = message;

@rpc
func authentication_succeed(sessionToken)-> void:
	print("good to change scenes")
	print(sessionToken)
	error_label.text = ""
	AuthNetCredentials.user = user_line_edit.text
	AuthNetCredentials.session_token = sessionToken
	get_tree().change_scene_to_packed(lobbyScene)
