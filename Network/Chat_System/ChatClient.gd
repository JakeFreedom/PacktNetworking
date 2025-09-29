extends Control


const PORT = 3000
const ADDRESS = "localhost"



func _ready() -> void:
	var auth_ID = get_multiplayer_authority()
	rpc_id(auth_ID, "RetrieveAvatar", AuthNetCredentials.user, AuthNetCredentials.session_token)
	
	


@rpc
func RetrieveAvatar(user, sessionToken) -> void:
	pass

@rpc
func AddAvatar(name, texture) -> void:
	print("Add avatar Method")
	pass

@rpc
func authenticate_player(user, password):
	pass


@rpc
func authentication_failed(error_message):
	pass


@rpc
func authentication_succeed(user, session_token):
	pass

@rpc
func ClearAvatar() -> void:
	print("clear avatars")
	pass
