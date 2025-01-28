class_name GameOverArea extends Area2D

signal game_over

@export var min_speed: float = 0.025

var _game_over: bool = false

func _process(_delta: float) -> void:
	if not _game_over:
		var contacts: Array[Node2D] = get_overlapping_bodies()
		
		for body: Node2D in contacts:
			if (
					body is Fruit and body.linear_velocity.x < min_speed
					and body.linear_velocity.y < min_speed and not body.is_waiting
			):
				body.get_child(1).disabled = true
				body.freeze = true
				_game_over = true
				await get_tree().create_timer(0.1).timeout
				_animate_body(body)
				game_over.emit()
				break


func _animate_body(body: Fruit) -> void:
	var fruit_sprite: Sprite2D = body.get_child(0)
	fruit_sprite.material = ShaderMaterial.new()
	fruit_sprite.material.shader = load("res://themes/blink_shader.gdshader")
	fruit_sprite.material.set_shader_parameter("blink_intensity", 0.0)
	
	var tween := create_tween()
	tween.set_loops()
	tween.tween_interval(0.5)
	tween.tween_property(fruit_sprite.material, "shader_parameter/blink_intensity", 0.85, 0.7)
	tween.tween_property(fruit_sprite.material, "shader_parameter/blink_intensity", 0.0, 0.7)
	tween.tween_interval(0.5)
