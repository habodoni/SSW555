# mock_astronaut.gd
extends CharacterBody2D  # Should extend CharacterBody2D to match real player

# --- Simulated Player Properties ---
var health: int = 50
var MAX_HEALTH: int = 100
var repair_skill: float = 2.0
var minigame_active: bool = false

# --- Simulated Player Method ---
func increase_health(amount: int) -> void:
	health = min(health + amount, MAX_HEALTH)
