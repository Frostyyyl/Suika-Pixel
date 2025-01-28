extends Node

enum Scenes {
	Menu, 
	Game,
}

var current_scene: int = 0
var _scenes := {
	Scenes.Menu: "res://scenes/menu/menu.tscn",
	Scenes.Game: "res://scenes/game/game.tscn",
}

func load_scene(scene: Scenes) -> void:
	if current_scene == Scenes.Game:
		SaveManager.save_game()
	SaveManager.save_settings()
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", _scenes[scene])
	current_scene = scene


func quit_game() -> void:
	get_tree().call_deferred("quit")
