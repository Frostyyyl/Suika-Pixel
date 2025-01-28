extends Node2D

enum Fruits {
	CHERRY, 
	STRAWBERRY, 
	GRAPE, 
	LEMON, 
	ORANGE, 
	APPLE, 
	PEAR, 
	PEACH, 
	DRAGONFRUIT, 
	MELON, 
	WATERMELON,
}

var time_between_merges: float = 0.1
var window_size := Vector2(450, 800)
var points : Array[int] = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66]
var random := RandomNumberGenerator.new()
var fruit_material: PhysicsMaterial = load("res://objects/fruits/fruit_material.tres")
var highscore: int = 0
var prefabs := {
	Fruits.CHERRY: load("res://objects/fruits/prefabs/cherry.tscn"),
	Fruits.STRAWBERRY: load("res://objects/fruits/prefabs/strawberry.tscn"),
	Fruits.GRAPE: load("res://objects/fruits/prefabs/grape.tscn"),
	Fruits.LEMON: load("res://objects/fruits/prefabs/lemon.tscn"),
	Fruits.ORANGE: load("res://objects/fruits/prefabs/orange.tscn"),
	Fruits.APPLE: load("res://objects/fruits/prefabs/apple.tscn"),
	Fruits.PEAR: load("res://objects/fruits/prefabs/pear.tscn"),
	Fruits.PEACH: load("res://objects/fruits/prefabs/peach.tscn"),
	Fruits.DRAGONFRUIT: load("res://objects/fruits/prefabs/dragonfruit.tscn"),
	Fruits.MELON: load("res://objects/fruits/prefabs/melon.tscn"),
	Fruits.WATERMELON: load("res://objects/fruits/prefabs/watermelon.tscn"),
}

func _ready() -> void:
	random.randomize()
