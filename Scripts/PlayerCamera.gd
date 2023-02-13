extends InterpolatedCamera

func _on_Player_set_camera_target(player):
	print("JU")	
	set_target(player)
	make_current()
