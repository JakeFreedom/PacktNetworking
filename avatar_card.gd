extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label



func UpdateData(name, texturePath) -> void:
	texture_rect.texture = load(texturePath)
	label.text=name
	pass
