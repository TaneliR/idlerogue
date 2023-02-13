extends KinematicBody

func _ready():
	$AnimatedSprite3D.play("death")

	# connect the animation finishing to the function "destroy" send it the animation
	$AnimatedSprite3D.connect("animation_finished", self, "destroy", [self])

func destroy(instance):
	instance.queue_free()
