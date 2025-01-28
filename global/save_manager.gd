extends Node

var _game_file_path: String = "user://game.json"
var _settings_file_path: String = "user://settings.json"

func save_game() -> void:
	var save_file := FileAccess.open(_game_file_path, FileAccess.WRITE)
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("PersistGame")
	for node: Node in save_nodes:
		if not node.has_method("save"):
			print("Persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		var node_data: Dictionary = node.call("save")
		var json_string: String = JSON.stringify(node_data)
		save_file.store_line(json_string)


func load_game() -> void:
	if not FileAccess.file_exists(_game_file_path):
		return
		
	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("PersistGame")
	var save_file := FileAccess.open(_game_file_path, FileAccess.READ)
	for node: Node in save_nodes:
		var json_string: String = save_file.get_line()
		var json := JSON.new()
		var parse_result: int = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in " \
			, json_string, " at line ", json.get_error_line())
			continue
		var node_data: Dictionary = json.get_data()
		for i: String in node_data.keys():
			node.set(i, node_data[i])


func save_settings() -> void:
	var save_file := FileAccess.open(_settings_file_path, FileAccess.WRITE)
	for i: int in AudioServer.bus_count:
		var save_dir := {
			i: db_to_linear(AudioServer.get_bus_volume_db(i))
		}
		var json_string: String = JSON.stringify(save_dir)
		save_file.store_line(json_string)


func load_settings() -> void:
	if not FileAccess.file_exists(_settings_file_path):
		return
		
	var save_file := FileAccess.open(_settings_file_path, FileAccess.READ)
	for i: int in AudioServer.bus_count:
		var json_string: String = save_file.get_line()
		var json := JSON.new()
		var parse_result: int = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in " \
			, json_string, " at line ", json.get_error_line())
			continue
		var node_data: Dictionary = json.get_data()
		for key: String in node_data.keys():
			AudioServer.set_bus_volume_db(i, linear_to_db(node_data[key]))
