extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var maximum = 140
var minimum = 50
var step = 2
onready var currentFov = 120
onready var sky = preload("res://skyyyy.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var newSky = sky.duplicate()
	currentFov = currentFov + step * delta
	newSky.background_sky_custom_fov = currentFov
	self.environment = newSky
	if (currentFov <= minimum || currentFov >= maximum):
		step *= -1
	
	


func _on_Player_money_changed():
	pass # Replace with function body.
