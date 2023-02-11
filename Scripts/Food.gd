extends KinematicBody

var velocity = Vector3.ZERO

var player = null
var being_picked_up

func _physics_process(delta):
	if being_picked_up == false:
		move_and_slide(Vector3(0, 200, 0) * 420 * delta, Vector3.ZERO)
	elif (player != null &&  being_picked_up == true):
		var direction = global_transform.origin.direction_to(player.global_transform.origin)
		move_and_slide(direction * 200 * delta, Vector3.ZERO)
		var  distance = global_transform.origin.distance_to(player.global_transform.origin)
		if distance < 4:
			queue_free()
	move_and_slide(velocity, Vector3.UP)

func pick_up_item(body):
	player = body
	being_picked_up = true
