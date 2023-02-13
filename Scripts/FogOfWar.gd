extends GridMap


# # Declare member variables here. Examples:
# # var a = 2
# # var b = "text"


# # Called when the node enters the scene tree for the first time.
# func _ready():
# 	pass # Replace with function body.


# # Called every frame. 'delta' is the elapsed time since the previous frame.
# #func _process(delta):
# #	pass
func generate_fog(size):
	pass
	for x in range(size):
		for z in range(size):
			set_cell_item(x,0,z,0)

func _on_GridMap_move_camera(size):
	pass
	generate_fog(size)
