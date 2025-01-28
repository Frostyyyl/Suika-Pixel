extends Node

@export var root_paths : Array[NodePath]

func _ready() -> void:
	for path: NodePath in root_paths:
		install_sounds(get_node(path))


func install_sounds(node: Node) -> void:
	if node is TextButton:
		node.mouse_entered.connect(Audio.play_sound.bind(Audio.Sounds.UI_HOVER))
		node.pressed.connect(Audio.play_sound.bind(Audio.Sounds.UI_CLICK))
	elif node is Button:
		node.mouse_entered.connect(Audio.play_sound.bind(Audio.Sounds.UI_HOVER))
		node.pressed.connect(Audio.play_sound.bind(Audio.Sounds.UI_CLICK))
	elif node is HSlider:
		node.mouse_entered.connect(Audio.play_sound.bind(Audio.Sounds.UI_HOVER))
