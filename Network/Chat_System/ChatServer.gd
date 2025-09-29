extends Control


const PORT = 3000


var peer = ENetMultiplayerPeer.new()
var dataBase = {}
var loggedUsers = {}
@export var dbFile: String

@onready var chat: Control = $ChatControl

func _ready() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print(peer.get_unique_id())
	
	
	LoadDatabase()
	
	
func LoadDatabase() -> void:
	var file = FileAccess.open(dbFile, FileAccess.READ)
	var fileContents = file.get_as_text()
	dataBase = JSON.parse_string(fileContents)
	pass
	
@rpc
func authentication_succeed(sessionToken)-> void:
	pass
	
@rpc
func authentication_failed() -> void:
	pass
	
@rpc
func AddAvatar(name, texture) -> void:
	pass
	
@rpc
func ClearAvatar() -> void:
	pass
	
	
@rpc("any_peer", "call_remote")
func authenticate_player(user, password)-> void:
	var peer_id = multiplayer.get_remote_sender_id()
	#check to see if user is in the db
	if not user in dataBase:
		rpc_id(peer_id, "authentication_failed", "User Doesn't Exist")
	elif dataBase[user]['password'] == password:
		var token = randi()
		loggedUsers[user] = token
		rpc_id(peer_id, "authentication_succeed", token)
	else:
		rpc_id(peer_id, "authentication_failed", "Password Incorrect")
		
@rpc("any_peer", "call_remote")
func RetrieveAvatar(user, sessionToken) -> void:
	print("Re avatar")
	print(sessionToken)
	var peerToCall = multiplayer.get_remote_sender_id()
	if not user in loggedUsers:
		return
		
	if sessionToken == loggedUsers[user]:
		print("clear avatars")
		rpc("ClearAvatar")
		chat.rpc_id(peerToCall, "SetAvatarName", dataBase[user]['name'])
		for users in loggedUsers:
			rpc("AddAvatar", "set name", "set_path")
		
	pass
