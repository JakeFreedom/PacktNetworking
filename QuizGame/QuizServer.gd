extends Control

const PORT = 3000

var peer = ENetMultiplayerPeer.new()
@export var db: String = ""
@export_file("*.tscn") var ChangeToServerSceneFile
@export var questionFiles: Array[String]
var userDatabase = {}
var loggedUser = {}
func _ready() -> void:
	var peerID = peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	LoadDatabase()
	for item in questionFiles:
		var button: Button = Button.new()
		#button.name = str(item)
		button.pressed.connect(LoadQuestionsDB.bind(item))
		button.text = item
		get_node("VBoxContainer").add_child(button)


func LoadQuestionsDB(file) -> void:
	AuthNetCredentials.questionDatabaseFile = "1"
	pass

func LoadDatabase() -> void:
	var file = FileAccess.open(db, FileAccess.READ)
	var file_contents = file.get_as_text()
	userDatabase = JSON.parse_string(file_contents)


@rpc("any_peer", "call_remote")
func AuthenticatePlayer(username, password) -> void:
	var remoteCallingPeer = multiplayer.get_remote_sender_id()
	
	if username not in userDatabase:
		rpc_id(remoteCallingPeer, "AuthenticationFailed", "User not found")
	#check to see if the password is correct
	elif not userDatabase[username]['password'] == password:
		rpc_id(remoteCallingPeer, "AuthenticationFailed", "Password incorrect")
	elif username in loggedUser:
		rpc_id(remoteCallingPeer, "AuthenticationFailed", "User already logged in")
		#authentication passed, a very weak pass but sure
	elif userDatabase[username]['password'] == password:
		var token = randi()
		loggedUser[username] = token
		rpc_id(remoteCallingPeer, "AuthenticationSuccess", token)
		rpc("ClearLoggedPlayers")
		for user in loggedUser.keys():
			rpc("AddLoggedPlayers", userDatabase[user]['name'])
		pass


@rpc("any_peer", "call_remote")
func StartGame() -> void:
	#print("this is the server start game method")
	#now we will call all the client and tell them that the game is starting
	rpc("StartGame")
	#Here we need to tell the server it needs to changes it's scene as well
	get_tree().change_scene_to_file(ChangeToServerSceneFile)

@rpc
func AuthenticationSuccess() -> void:
	pass

@rpc
func AuthenticationFailed(message) -> void:
	pass

@rpc
func AddLoggedPlayers(playerName) -> void:
	pass
	
@rpc
func ClearLoggedPlayers() -> void:
	pass
