extends Control

@export_file("*.tscn") var ClientQuizScreen

@onready var user_line_edit: LineEdit = $UserLineEdit
@onready var password_line_edit: LineEdit = $PasswordLineEdit
@onready var login: Button = $Login
@onready var label: Label = $ColorRect/Label
@onready var error_label: Label = $ErrorLabel
@onready var start_button: Button = $StartButton

var peer = ENetMultiplayerPeer.new()
func _ready() -> void:
	var peerID = peer.create_client("192.168.90.171", 3000)
	login.pressed.connect(OnLogin_Pressed)
	multiplayer.multiplayer_peer = peer
	label.text = "Players in the match: \n \n"
	start_button.hide()
	start_button.pressed.connect(OnStartButton_Pressed)
	multiplayer.connected_to_server.connect(WeAreConnectedToTheServer)
	
	
	
func WeAreConnectedToTheServer() -> void:
	print("We are connected to the server")

func OnLogin_Pressed() -> void:
	var userName = user_line_edit.text
	var password = password_line_edit.text
	#send login credentials to the server
	rpc("AuthenticatePlayer", userName, password)
	
#here we will call the server and have it start the game
func OnStartButton_Pressed() -> void:
	#Call the server and indicate we are ready to start the game
	rpc_id(get_multiplayer_authority(), "StartGame")

@rpc
func AuthenticatePlayer(username, password) -> void:
	pass


@rpc("any_peer", "call_remote")
func AuthenticationFailed(message) -> void:
	print("Auth failed")
	pass


@rpc
func AuthenticationSuccess(token) -> void:
	error_label.text = "Login Successful"
	AuthNetCredentials.user = user_line_edit.text
	AuthNetCredentials.session_token = token
	user_line_edit.hide()
	password_line_edit.hide()
	login.hide()
	start_button.show()
	
	pass
	
@rpc
func AddLoggedPlayers(playerName) -> void:
	label.text += "\n%s" % playerName
	
@rpc
func ClearLoggedPlayers() -> void:
	label.text = "Players in match: \n"
	
@rpc("authority", "call_local")
func StartGame() -> void:
	#print("Server called and said its time to start the game")
	get_tree().change_scene_to_file(ClientQuizScreen)
