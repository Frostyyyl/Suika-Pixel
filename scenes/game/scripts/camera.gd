extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(Data.window_size.x / 2 - get_viewport_rect().size.x / 2, \
			Data.window_size.y - get_viewport_rect().size.y)
	pass
