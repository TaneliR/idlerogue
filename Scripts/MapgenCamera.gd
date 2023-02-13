extends Camera

func _on_GridMap_move_camera(size):
	transform.origin = Vector3(0, size * 2, size / 2)
