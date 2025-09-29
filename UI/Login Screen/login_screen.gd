extends Control
@onready var user_name: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/userName
@onready var password: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer2/password
@onready var login: Button = $MarginContainer/VBoxContainer/HBoxContainer3/Login
@onready var error_label: Label = $MarginContainer/VBoxContainer/ErrorLabel

@export var UserAvatarScene: PackedScene
@export var lobbyScene: PackedScene

const PORT = 3000
const ADDRESS = "192.168.90.171"

var peer = ENetMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	peer.create_client(ADDRESS,PORT)
	multiplayer.multiplayer_peer = peer
	login.pressed.connect(_login_pressed)
	multiplayer.connected_to_server.connect(WeAreConnectedToTheServer)
	#print(multiplayer.get_unique_id())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func WeAreConnectedToTheServer() -> void:
	pass
	
func send_credentials() -> void:
	var userName = user_name.text
	var password = password.text

	rpc_id(get_multiplayer_authority(), "AuthenticatePlayer", userName, password)
	#var message = {'authenticate_credentials': {'user': user_name.text, 'password': password.text}}
	#var packet = PacketPeerUDP.new()
	#packet.connect_to_host(ADDRESS, PORT)#send out and connect address on specific port
	#packet.put_var(JSON.stringify(message)) # put the login information into JSON format
	#while packet.wait() == OK: # or ZERO
		#var data = JSON.parse_string(packet.get_var())
		#if "token" in data:#This we will create at a later date
			#error_label.text = "Logged."
			#AuthNetCredentials.user = message['authenticate_credentials']['user']
			#AuthNetCredentials.session_token = data['token']
			#get_tree().change_scene_to_packed(UserAvatarScene)
			#break
		#else:
			#error_label.text = "Login Failed, please check your creds!"
			#break
	
func _login_pressed() -> void:
	if user_name.text != "":
		send_credentials()
	pass

@rpc
func AddAvator() -> void:
	pass
	
@rpc
func ClearAvatars() -> void:
	pass
	
@rpc("any_peer","call_remote")
func RetrieveAvatar(user, sessionToken) -> void:
	pass	

@rpc
func AuthenticatePlayer(user, password)->void:
	pass

@rpc("call_remote")
func AuthenticateFailed(errorMessage) -> void:
	error_label.text = errorMessage
	
@rpc("any_peer", "call_remote")
func AuthenticateSuccessful(sessionToken) -> void:
	AuthNetCredentials.user = user_name.text
	AuthNetCredentials.session_token = sessionToken
	get_tree().change_scene_to_packed(lobbyScene)
