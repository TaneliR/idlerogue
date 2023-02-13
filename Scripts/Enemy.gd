extends KinematicBody

var moving = false;
var tile_size = 2;
var max_health = 100;
var health;
var directions = [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]
var rng = RandomNumberGenerator.new()
onready var engaging = false;

func _ready():
	health = max_health;
	add_to_group("enemy")
	rng.randomize()
	move(null)

func destroy():
	var death_animation = preload("res://Scenes/Enemy_death.tscn").instance()
	get_parent().add_child(death_animation)
	death_animation.global_transform.origin = global_transform.origin
	queue_free()

func move(player):
	var randomIndex = rng.randi_range(0, directions.size() - 1)
	var next_step = directions[randomIndex]
	if (engaging):
		print("playerpos")
		print(player.transform.origin)
		print("ownpos")
		print(transform.origin)

		var step = transform.origin.direction_to(player.transform.origin).normalized()
		print("STEPPA")
		print(step)
		next_step = Vector3(round(step.x), 0, 0) if (abs(step.x) > abs(step.z)) else Vector3(0, 0, round(step.z))
		
	print(next_step * tile_size)
	var col = move_and_collide(next_step * tile_size);
	if (col && engaging):
		print(col.collider.name)
	
func take_damage(dmg):
	health -= dmg
	engaging = true;
	$Blood.emitting = true;
	$Healthbar3D.update(health, max_health)
	if (health <= 0):
		destroy()
