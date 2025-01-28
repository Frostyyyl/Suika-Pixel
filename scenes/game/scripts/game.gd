extends Node2D

@export var time_between_spawns: float = 0.6
@export var time_on_game_over_screen: float = 1.0
@export var y_drop_pos: int = 150
@export var new_fruit_offset: Vector2 = Vector2i(50, 50)
@export var slide_speed: int = 200

var _current_fruit: Fruit: set = _set_current_fruit
var _new_fruit: Fruit
var _fruit_offset: int
var _can_spawn_fruit: bool = true
var _are_inputs_enabled: bool = true: set = set_inputs
var _is_ui_enabled: bool = false: set = set_ui
var _is_game_paused: bool = false: set = set_pause
var _is_game_over: bool = false
var _x_min_pos: int = 21
var _x_max_pos: int = Data.window_size.x - _x_min_pos

#@onready var _current_x: float = Data.window_size.x / 2
@onready var _new_fruit_pos := Vector2(Data.window_size.x / 2 + get_viewport_rect().size.x/2 \
		- new_fruit_offset.x, Data.window_size.y - get_viewport_rect().size.y + new_fruit_offset.y)
@onready var hint := $ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveManager.load_game()
	SignalBus.fruits_merged.connect(_merge_fruits)
	_current_fruit = _spawn_fruit()
	_new_fruit = _spawn_fruit()
	hint.position.y = y_drop_pos
	hint.position.x = _current_fruit.position.x


func _input(event: InputEvent) -> void:
	if (
		_are_inputs_enabled and not _is_ui_enabled 
		and event is InputEventMouseButton and event.is_released()
	):
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if _can_spawn_fruit and not _is_game_over:
					_can_spawn_fruit = false
					_drop_fruit(_current_fruit)
					hint.visible = false
					await get_tree().create_timer(time_between_spawns).timeout
					while _is_game_paused:
						await get_tree().create_timer(time_between_spawns / 2).timeout
					_current_fruit = _new_fruit
					hint.position.x = _current_fruit.position.x - hint.size.x / 2
					hint.visible = true
					_new_fruit = _spawn_fruit()
					_can_spawn_fruit = true
				
				elif _is_game_over:
					SceneManager.load_scene(SceneManager.Scenes.Game)
	#elif (
		#_are_inputs_enabled and not _is_ui_enabled 
		#and event.is_action_pressed("select")
	#):
		#if _can_spawn_fruit and not _is_game_over:
			#_can_spawn_fruit = false
			#_drop_fruit(_current_fruit)
			#hint.visible = false
			#await get_tree().create_timer(time_between_spawns).timeout
			#while _is_game_paused:
				#await get_tree().create_timer(time_between_spawns / 2).timeout
			#_current_fruit = _new_fruit
			#hint.position.x = _current_fruit.position.x - hint.size.x / 2
			#hint.visible = true
			#_new_fruit = _spawn_fruit()
			#_can_spawn_fruit = true


#func _physics_process(delta: float) -> void:
	#if (
		#not _is_game_paused and _can_spawn_fruit and
		#_are_inputs_enabled and not _is_ui_enabled 
	#):
		#if Input.is_action_pressed("right"):
			#_current_x = min(_x_max_pos - _fruit_offset, _current_fruit.position.x \
					#+ slide_speed * delta)
			#_current_fruit.position.x = _current_x
			#
			#hint.position.x = _current_x - hint.size.x / 2
		#elif Input.is_action_pressed("left"):
			#_current_x = max(_x_min_pos + _fruit_offset, _current_fruit.position.x 
					#- slide_speed * delta)
			#_current_fruit.position.x = _current_x
			#
			#hint.position.x = _current_x - hint.size.x / 2


func _process(_delta: float) -> void:
	if not _is_game_paused and _can_spawn_fruit:
		var new_pos: int = min(_x_max_pos - _fruit_offset, \
				max(_x_min_pos + _fruit_offset, get_global_mouse_position().x))
		_current_fruit.position.x = new_pos
		hint.position.x = new_pos - hint.size.x / 2


func on_game_over() -> void:
	$"GUI/GameOverScreen".visible = true
	_is_game_paused = true
	await get_tree().create_timer(time_on_game_over_screen).timeout
	_is_game_over = true


func set_inputs(value: bool) -> void:
	_are_inputs_enabled = value


func set_pause(value: bool) -> void:
	if value:
		_is_game_paused = value
		get_tree().paused = value
	elif not _is_game_over:
		_is_game_paused = value
		get_tree().paused = value


func set_ui(value: bool) -> void:
	_is_ui_enabled = value



# NOTE: Side effect: changes _fruit_offset
func _set_current_fruit(fruit: Fruit) -> void:
	_current_fruit = fruit
	_fruit_offset = fruit.get_child(1).shape.radius
	_current_fruit.position = Vector2(min(_x_max_pos - _fruit_offset, max(_x_min_pos \
			+ _fruit_offset, get_global_mouse_position().x)), y_drop_pos)
			# _current_x for windows


func _drop_fruit(fruit: Fruit) -> void:
	Audio.play_random_sound(Audio.RandomSounds.FRUIT_DROP)
	fruit.freeze = false
	fruit.get_child(1).disabled = false


func _spawn_fruit() -> Fruit:
	var choice: int = Data.random.randi_range(0, 4)
	var instance: Fruit = Data.prefabs[choice].instantiate()
	add_child(instance)
	
	instance.position = _new_fruit_pos + Vector2(0, instance.get_child(1).shape.radius)
	instance.get_child(1).disabled = true
	instance.freeze = true
	return instance


func _merge_fruits(type: int, first_body: Fruit, second_body: Fruit) -> void:
	if not _is_game_paused:
		SignalBus.emit_signal("score_increased", Data.points[type])
		Audio.play_increasing_sound(Audio.IncreasingSounds.FRUIT_MERGE)
		var positions: Array[Vector2] = [first_body.position, second_body.position]
		var pos: Vector2 = (positions[0] + positions[1]) / 2
		
		first_body.free()
		second_body.queue_free()
		
		var particle: GPUParticles2D
		match type:
			Data.Fruits.WATERMELON:
				for i in range(positions.size()):
					var confetti: GPUParticles2D = Particles.confetti.instantiate()
					add_child(confetti)
					confetti.position = positions[i]
					confetti.emitting = true
				return
			Data.Fruits.MELON:
				particle = Particles.watermelon_particle.instantiate()
			Data.Fruits.DRAGONFRUIT:
				particle = Particles.melon_particle.instantiate()
		
		if particle != null:
			add_child(particle)
			particle.position = pos
			particle.emitting = true
		
		var instance: Fruit
		if type != Data.Fruits.WATERMELON and type in Data.prefabs:
			instance = Data.prefabs[type + 1].instantiate()
		
		add_child(instance)
		instance.just_merged = true
		instance.set_position(pos)

