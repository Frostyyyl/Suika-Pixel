extends Node

# While adding any sound, a new player, as well as a path to the sound must be declared 
enum Sounds {
	UI_CLICK, 
	UI_HOVER,
}

enum RandomSounds {
	FRUIT_DROP,
}

enum IncreasingSounds {
	FRUIT_MERGE,
}

var _song := load("res://audio/music.mp3")

# Sounds
var _players := {
	Sounds.UI_CLICK: AudioStreamPlayer.new(),
	Sounds.UI_HOVER: AudioStreamPlayer.new(),
}
var _paths := {
	Sounds.UI_CLICK: load("res://audio/sounds/ui_click.ogg"),
	Sounds.UI_HOVER: load("res://audio/sounds/ui_hover.ogg"),
}

# Random sounds
var _random_players := {
	RandomSounds.FRUIT_DROP: AudioStreamPlayer.new(),
}
var _random_paths := {
	RandomSounds.FRUIT_DROP: [
		load("res://audio/sounds/fruit_drop1.ogg"),
		load("res://audio/sounds/fruit_drop2.ogg"),
		load("res://audio/sounds/fruit_drop3.ogg"),
	]
}

# Increasing sounds
# NOTE: In order to add more parallel sounds the _last_played variable,
# and the _times_played variable need to be turned into a list,
# as well as the play_increasing_sound method must be changed accordingly

var _last_played: int = 0
var _times_played: int = 0
var _increasing_players := {
	IncreasingSounds.FRUIT_MERGE: [
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
		AudioStreamPlayer.new(),
	]
}
var _increasing_paths := {
	IncreasingSounds.FRUIT_MERGE: [
		load("res://audio/sounds/merge_do.wav"),
		load("res://audio/sounds/merge_re.wav"),
		load("res://audio/sounds/merge_mi.wav"),
		load("res://audio/sounds/merge_fa.wav"),
		load("res://audio/sounds/merge_sol.wav"),
		load("res://audio/sounds/merge_la.wav"),
		load("res://audio/sounds/merge_si.wav"),
		load("res://audio/sounds/merge_do_2.wav"),
	]
}

func _ready() -> void:
	GlobalPlayer.stream = _song
	GlobalPlayer.bus = "Music"
	GlobalPlayer.finished.connect(_replay.bind(GlobalPlayer))
	GlobalPlayer.play()
	
	for i: int in _paths:
		add_child(_players[i])
		_players[i].stream = _paths[i]
		_players[i].bus = "Sfx"

	for i: int in _random_players:
		add_child(_random_players[i])
		_random_players[i].bus = "Sfx"

	for i: int in _increasing_players:
		for j: int in _increasing_players[i].size():
			add_child(_increasing_players[i][j])
			_increasing_players[i][j].stream = _increasing_paths[i][j]
			_increasing_players[i][j].bus = "Sfx"
			_increasing_players[i][j].volume_db = 7.0


func play_sound(sound: int) -> void:
	_players[sound].play()


func play_random_sound(sound: int) -> void:
	_random_players[sound].stream = _random_paths[sound][Data.random.randi_range(0, \
			len(_random_paths[sound]) - 1)]
	_random_players[sound].play()


func play_increasing_sound(sound: int) -> void:
	if (Time.get_ticks_msec() - _last_played) / 1000 < Data.time_between_merges * 2:
		_last_played = Time.get_ticks_msec()
		_times_played += 1
		if _times_played < _increasing_paths[sound].size():
			_increasing_players[sound][_times_played].play()
		else:
			_increasing_players[sound][-1].play()
	else:
		_last_played = Time.get_ticks_msec()
		_times_played = 0
		_increasing_players[sound][0].play()


func _replay(player: AudioStreamPlayer) -> void:
	player.play()
