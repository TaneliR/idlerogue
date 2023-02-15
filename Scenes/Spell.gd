extends KinematicBody

export var speed = 250
export var g = Vector3.DOWN * .02
export (bool) var gravity = false

var velocity = Vector3.ZERO

func _physics_process(delta):
	if gravity:
		velocity += g * delta
	var col = move_and_collide(velocity * speed * delta)
	if (col):
		queue_free()
	# look_at(transform.origin + velocity.normalized(), Vector3.UP)
	# transform.origin += velocity * speed * delta
	# var bodies = get_colliding_bodies()
	# for body in bodies:
	# 	print(body)
	# 	if body.is_in_group("wall"): 
	# 		queue_free()

func shoot(dir):
	velocity += dir
	
