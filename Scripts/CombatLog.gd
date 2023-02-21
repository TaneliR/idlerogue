extends Node2D

onready var combat_log = ""

func _ready():
	TickManager.connect("update_log", self, "_on_Update_log")

func _on_Update_log(text):
	combat_log += text
	$Panel/Background/Log.append_bbcode(text)
