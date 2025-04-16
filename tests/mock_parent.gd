extends Node

var minigame_active := true

func set_minigame_active(active: bool) -> void:
	minigame_active = active
	print("MockParent: set_minigame_active called with", active)
