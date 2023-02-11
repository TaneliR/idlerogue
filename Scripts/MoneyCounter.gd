extends Node2D

func _on_Player_money_changed(value):
	$Money.text = value as String
