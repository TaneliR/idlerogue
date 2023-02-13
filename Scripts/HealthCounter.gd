extends Node2D

func _on_Player_update_health(value):
	$Health.text = value as String
