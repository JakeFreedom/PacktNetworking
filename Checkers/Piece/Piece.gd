class_name Piece
extends Node2D

signal selected
signal deselected
signal MouseHover

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
	area_2d.area_entered.connect(_on_area_2d_entered)
	area_2d.area_exited.connect(_on_area_2d_exited)

func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton:
		print(event)
		if event.button_index == 1 and event.pressed:
			select()
	if event is InputEventMouseMotion:
		print(event)

func _on_area_2d_entered() -> void:
	print("enter")
	pass

func _on_area_2d_exited() -> void:
	print("exit")
	pass


func select() -> void:
	if not is_selected:
		selected_color_rect.visible = true
		is_selected = true
		selected.emit()
	else:
		OnDeselected()


func _set_is_king(_value)->void:
	pass


func OnDeselected()-> void:
	selected_color_rect.visible = false
	is_selected = false
	deselected.emit()
