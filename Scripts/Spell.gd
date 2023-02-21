extends KinematicBody

export var damage = 100
export var speed = 250
export var g = Vector3.DOWN * .02
export (bool) var gravity = false

onready var stop = false
onready var spell_owner

var velocity = Vector3.ZERO

func _physics_process(delta):
	if !stop:
		if gravity:
			velocity += g * delta
		var col = move_and_collide(velocity * speed * delta)
		if (col):
			stop = true
			if(col.collider.is_in_group("enemy")):
				var spell_damage = randi() % damage + 1
				var attack_string = "hit [color=red]%s[/color] for [shake rate=8 level=5][color=red]%s[/color][/shake] [code][color=gray](%sd%s)[/color][/code] damage." % [col.collider.info_name, spell_damage, "1", damage]
				TickManager.send_log_entry("[color=green]Player[/color]", attack_string)
				col.collider.take_damage(spell_damage, spell_owner)
			yield(get_tree().create_timer(.35), "timeout")
			destruct()

func destruct():
	queue_free()
func shoot(dir, from):
	spell_owner = from
	velocity += dir
	
