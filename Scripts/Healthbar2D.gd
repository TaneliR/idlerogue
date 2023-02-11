extends TextureProgress

onready var bar_green = preload("res://Assets/barHorizontal_green_mid 200.png")
onready var bar_yellow = preload("res://Assets/barHorizontal_yellow_mid 200.png")
onready var bar_red = preload("res://Assets/barHorizontal_red_mid 200.png")

func update_bar(amount, full):
	texture_progress = bar_green
	if amount < 0.75 * full:
		texture_progress = bar_yellow
	if value < 0.45 * full:
		texture_progress = bar_red
	value = amount
