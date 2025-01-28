extends MarginContainer

var highscore: int: set = set_highscore, get = get_highscore
var score: int = 0: set = set_score

@onready var _highscore_node: Label = $Container/Row/Best
@onready var _score_node: Label = $Row/Score

func _ready() -> void:
	SignalBus.score_increased.connect(increase_score)
	_score_node.custom_minimum_size.x = get_viewport_rect().size.x - (Data.window_size.x - size.x) \
			- ($Row/NextText.size.x + $Row/ScoreText.size.x + 16)


func set_score(value: int) -> void:
	score = value
	_score_node.text = str(score)


func get_highscore() -> int:
	return Data.highscore


func set_highscore(value: int) -> void:
	Data.highscore = value
	_highscore_node.text = str(highscore)


func increase_score(value: int) -> void:
	score += value
	_score_node.text = str(score)


func save() -> Dictionary:
	var score_to_save: int = highscore
	if score > highscore:
		score_to_save = score
	var save_dict: Dictionary = {
		"highscore" = score_to_save
	}
	return save_dict
