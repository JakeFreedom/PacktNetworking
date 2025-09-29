class_name FreeCell
extends Area2D


signal Selected(cell_position)

# func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
# 	if event is InputEventMouseButton:
# 		if event.button_index == 1 and event.pressed:
# 			Select()
			
			
func Select() -> void:
	Selected.emit(self.position)
