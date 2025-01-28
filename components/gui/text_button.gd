class_name TextButton
extends MarginContainer

signal pressed

@export var text: String = "TEXT"

func _ready() -> void:
	$Label.text = text


func _on_pressed() -> void:
	pressed.emit()


func _on_mouse_entered() -> void:
	mouse_entered.emit()


func _load_scene(scene: int) -> void:
	SceneManager.load_scene(scene)


func _quit_game() -> void:
	SceneManager.quit_game()
