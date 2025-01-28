extends Node

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			if SceneManager.current_scene == SceneManager.Scenes.Game:
				SaveManager.save_game()
			SaveManager.save_settings()

func _ready() -> void:
	SaveManager.load_settings()
