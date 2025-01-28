extends HSlider

var _bus_index: int

@export var bus_name: String

func  _ready() -> void:
	_bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(_bus_index))


func _on_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(_value))
