extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export var avatar_card_scene: PackedScene# = preload("res://03.making-lobby-to-gather-players/AvatarCard.tscn")

#@onready var avatar_card_container = $AvatarCardsScrollContainer/AvatarCardsHBoxContainer
#@onready var avatar_card_container: HBoxContainer = $HBoxContainer
@onready var avatar_card_container: HBoxContainer = $ScrollContainer/HBoxContainer

var peer = ENetMultiplayerPeer.new()

func _ready():
	peer.create_client(ADDRESS, PORT)
	rpc_id(get_multiplayer_authority(), "RetrieveAvatar", AuthNetCredentials.user, AuthNetCredentials.session_token)


@rpc
func AddAvatar(avatar_name, texture_path):
	var avatar_card = avatar_card_scene.instantiate()
	avatar_card_container.add_child(avatar_card)
	await(get_tree().process_frame)
	avatar_card.UpdateData(avatar_name, texture_path)
@rpc
func ClearAvatars():
	for child in avatar_card_container.get_children():
		child.queue_free()


@rpc
func RetrieveAvatar(user, session_token):
	pass


@rpc
func AuthenticatePlayer(user, password):
	pass


@rpc
func AuthenticateFailed(error_message):
	pass


@rpc
func AuthenticateSuccessful(session_token):
	pass
