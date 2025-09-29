extends Node

const PORT = 3000
#var server = ENetMultiplayerPeer.new()
@export var data_base_file = "res://FakeDB.json"

var database = {}
var logged_users = {}
var server = UDPServer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	server.listen(PORT)
	load_database(data_base_file)
	#var error = server.create_server(PORT)
	#multiplayer.multiplayer_peer = server
	#multiplayer.peer_connected.connect(_peer_connected)
	#print("Server has started and listening for clients on port: " + str(PORT))
#
#
#func _peer_connected(id: int) -> void:
	#print("Peer ID: " + str(id))


func _process(_delta: float) -> void:
	#server.poll()
	#if server.is_connection_available():
		#var peer = server.take_connection()
		#var message = JSON.parse_string(peer.get_var())
		#if "authenticate_credentials" in message:
			#Authenticate_Player(peer, message)
		#elif "get_authentication_token" in message:
			#get_authentication_token(peer, message)
		#elif "get_avatar" in message:
			#get_avatar(peer,message)
			
			return
			
func Authenticate_Player(peer, message) -> void:
	var credentials = message['authenticate_credentials']
	var user = credentials["user"]
	var password = credentials["password"]
	if user in database.keys():
		if database[user]["password"] == password:
			var token = randi()
			logged_users[user] = token
			var response = {"token": token}
			peer.put_var(JSON.stringify(response))
			
		else:
			peer.put_var("")
	else:
		peer.put_var(JSON.stringify("nouser"))


func load_database(path_to_database_file) -> void:
	var file = FileAccess.open(path_to_database_file, FileAccess.READ)
	var file_contents = file.get_as_text()
	database = JSON.parse_string(file_contents)


func get_authentication_token(peer: PacketPeerUDP, message: Dictionary) -> void:
	
	var credentials = message
	if "user" in credentials:
		if credentials['token'] == logged_users[credentials['user']]:
			var token = logged_users[credentials['user']]
			var response = {'token': token, 'user': logged_users[credentials['user']]}
			peer.put_var(JSON.stringify(response))
			
func get_avatar(peer, message) -> void:
	print("getting avatar")
	var dictionary = message
	if "user" in message:
		var user = message["user"]
		if dictionary["token"] == logged_users[user]:
			var avatar = database[dictionary["user"]]["avatar"]
			var nickname = database[dictionary["user"]]["name"]
			var response = {"avatar": avatar,"name": nickname}
			print("just prior to send")
			peer.put_var(JSON.stringify(response))
