extends Node2D

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if (rng.randi() % 2 == 0):
		$TextureRect.texture = load("res://Assets/potu.png")
	else:
		$TextureRect.texture = load("res://Assets/food.png")
