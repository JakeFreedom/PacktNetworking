extends Control

@onready var label: Label = $HBoxContainer/Label
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect


const ADDRESS = "127.0.0.1"
const PORT = 3000

var peer = ENetMultiplayerPeer.new()

func _read() -> void:
	var peer_ID = peer.create_client(ADDRESS,PORT)
	multiplayer.multiplayer_peer = peer_ID
#func _ready() -> void:
	#var packet = PacketPeerUDP.new()
	#packet.connect_to_host(ADDRESS, PORT)
	#request_authenticationToken(packet)
#
#func request_authenticationToken(packet) -> void:
	#var request = {'get_authentication_token': true, 'user': AuthNetCredentials.user, 'token':AuthNetCredentials.session_token}
	#packet.put_var(JSON.stringify(request))
	##
	#while packet.wait() == OK:
		#var data = JSON.parse_string(packet.get_var())
#
		#if "token" in data:
			#if data['token'] == AuthNetCredentials.session_token:
				#request_avatar(packet)
		#break
			#
			#
#func request_avatar(packet) -> void:
	#var request = {"get_avatar": true, "token": AuthNetCredentials.session_token, "user": AuthNetCredentials.user}
	#packet.put_var(JSON.stringify(request))
	#
	#while packet.wait() == OK:
		#var data = JSON.parse_string(packet.get_var())
		#if "avatar" in data:
			#print(data["avatar"])
			#var texture = load(data["avatar"])
			#texture_rect.texture=texture
			#label.text = data["name"]
			#break
