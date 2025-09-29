extends Control

@export var serverScene: PackedScene
@export var lobbyScene: PackedScene

@onready var client: Button = $Client
@onready var server: Button = $Server


func _ready() -> void:
	client.pressed.connect(ClientClicked)
	server.pressed.connect(ServerClicked)
	
	
	
	
	
	
func ClientClicked() -> void:
	get_tree().change_scene_to_packed(lobbyScene)
	
	
func ServerClicked() -> void:
	get_tree().change_scene_to_packed(serverScene)
	
	

	
