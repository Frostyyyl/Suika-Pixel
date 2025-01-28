class_name Fruit
extends RigidBody2D

# Any fruits added to the directory MUST have Sprite2D under 
# first index and CollisionShape2D under second index

# Set any fruit id inside of the inspector

@export var fruit_id: Data.Fruits

var is_waiting: bool = false
var just_merged: bool = false: set = set_just_merged

var _time_on_merge: int = 0

func _ready() -> void:
	set_physics_material_override(Data.fruit_material)
	mass = 0.1 + 0.1 * fruit_id
	gravity_scale = 0.8
	contact_monitor = true
	max_contacts_reported = 5

func _process(_delta: float) -> void:
	var _passed_time: int = Time.get_ticks_msec() - _time_on_merge
	if just_merged and _passed_time / 1000 > Data.time_between_merges:
		just_merged = false
		
	var contacts: Array[Node2D] = get_colliding_bodies()
	for body: Node2D in contacts:
		if (
				body is Fruit and fruit_id == body.fruit_id 
				and get_instance_id() > body.get_instance_id()
		):
			if just_merged:
				is_waiting = true
				await get_tree().create_timer(Data.time_between_merges - _passed_time / 1000).timeout
				is_waiting = false
				# Prevent merging with a body if it is gone after waiting
				if body == null:
					break
			SignalBus.emit_signal("fruits_merged", fruit_id, body, self)
			break


# NOTE: Side effect: changes _time_start
func set_just_merged(value: bool) -> void:
	just_merged = value
	_time_on_merge = Time.get_ticks_msec()

