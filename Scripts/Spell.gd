extends KinematicBody

export var damage = 100
export var speed = 250
export var g = Vector3.DOWN * .02
export (bool) var gravity = false

onready var stop = false

var velocity = Vector3.ZERO

func _physics_process(delta):
	if !stop:
		if gravity:
			velocity += g * delta
		var col = move_and_collide(velocity * speed * delta)
		if (col):
			stop = true
			if(col.collider.is_in_group("enemy")):
				print("HIT enem")
				col.collider.take_damage(damage)
			yield(get_tree().create_timer(.35), "timeout")
			destruct()
	# look_at(transform.origin + velocity.normalized(), Vector3.UP)
	# transform.origin += velocity * speed * delta
	# var bodies = get_colliding_bodies()
	# for body in bodies:
	# 	print(body)
	# 	if body.is_in_group("wall"): 
	# 		queue_free()
func destruct():
	queue_free()
func shoot(dir):
	velocity += dir
	
