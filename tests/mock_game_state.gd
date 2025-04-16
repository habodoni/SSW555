extends Node

var _system_status = {
	"oxygen": false,
	"navigation": false,
}

func set_system_status(status: Dictionary) -> void:
	_system_status = status

func get_system_status() -> Dictionary:
	return _system_status
