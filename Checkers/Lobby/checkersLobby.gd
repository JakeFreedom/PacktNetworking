extends Control
@onready var login: Button = $Login
@onready var start: Button = $Start

@export var board:TileSet


func _ready()-> void:
	login.pressed.connect(LoginPressed)
	start.pressed.connect(StartPressed)
	board.tile_size = Vector2i(64,64)
	
	
	
	
func LoginPressed()-> void:
	pass
	
func StartPressed() -> void:
	pass
