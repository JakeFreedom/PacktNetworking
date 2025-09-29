extends Control
@export var client_scene: PackedScene
@export var server_scene: PackedScene

@onready var server: Button = $VBoxContainer/HBoxContainer/Server
@onready var client: Button = $VBoxContainer/HBoxContainer/Client



func _ready() -> void:
	server.pressed.connect(_on_server_pressed)
	client.pressed.connect(_on_client_pressed)
	
func _on_server_pressed() -> void:
	#Load Server Scene
	get_tree().change_scene_to_packed(server_scene)
	print("")
	pass
	
func _on_client_pressed() -> void:
	#Load Login Scene
	get_tree().change_scene_to_packed(client_scene)
