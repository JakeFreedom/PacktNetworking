class_name Piece
extends Node2D

signal selected
signal deselected

enum Teams{BLACK, WHITE}

@export var team: Teams = Teams.BLACK
@export var is_king = false: set = _set_is_king
@export var king_texture = preload("res://Checkers/Piece/WhiteKing.svg")


@onready var enanbled_color_rect: ColorRect = $EnanbledColorRect
@onready var selected_color_rect: ColorRect = $SelectedColorRect
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D

var is_selected = false

func _ready() -> void:
	area_2d.input_event.connect(_on_area_2d_input_event)

func _on_area_2d_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			select()
	pass








func select() -> void:
	print(name)
	pass


func _set_is_king(value)->void:
	pass
