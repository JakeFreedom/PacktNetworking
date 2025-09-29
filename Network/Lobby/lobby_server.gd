extends Control

#Constants
const PORT = 3000

#Export
@export var dataBaseFile: String


#On Ready

#Global Vars
var peer = ENetMultiplayerPeer.new()
var dataBase = {} #Dictionary to load the json/database into
var loggedInUsers = {} #Dictionary to hold what users are currently logged in

func _ready() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	LoadDatabase()
	
func LoadDatabase() -> void:
	var file = FileAccess.open(dataBaseFile, FileAccess.READ)
	var content = file.get_as_text()
	dataBase = JSON.parse_string(content)
	
	
@rpc("call_remote")
func AddAvatar(avatar_name, texture_path) -> void:
	pass
	
@rpc("call_remote")
func ClearAvatars() -> void:
	pass
	
@rpc("any_peer","call_remote")
func RetrieveAvatar(user, sessionToken) -> void:
	if not user in loggedInUsers:
		return
		
	if sessionToken == loggedInUsers[user]:
		rpc("ClearAvatars")
		for loggedIn_user in loggedInUsers:
			var user_name = dataBase[loggedIn_user]['name']
			var avatar = dataBase[loggedIn_user]['avatar']
			rpc("AddAvatar", user_name, avatar)
	
@rpc("any_peer","call_remote")
func AuthenticatePlayer(user, password) -> void:
	var peer_ID = multiplayer.get_remote_sender_id()
	if not user in dataBase:
		rpc_id(peer_ID, "AuthenticateFailed", "User Not Found")
	elif dataBase[user]['password'] == password:
		var token = randi()
		loggedInUsers[user] = token #store the now logged in user in the dictionary to track further RPC calls
		rpc_id(peer_ID, "AuthenticateSuccessful", token)
		
#Methods that just need to be here for a signature match
@rpc("call_remote")
func AuthenticateFailed(errorMessage) -> void:
	pass
	
@rpc("call_remote")
func AuthenticateSuccessful(sessionToken) -> void:
	pass
