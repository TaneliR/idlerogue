extends KinematicBody

var tile_size = 2;
var max_health = 100;
var attack_power = 1;
var hit_die = [2, 4]; # 2d4+1
var health;
var directions = [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]
var rng = RandomNumberGenerator.new()
onready var engaging = false;
onready var moving = false;
var player_instance;

func _ready():
	var _move = move_and_slide(Vector3(.5, .5, .5), Vector3.UP)
	# var _move = move_and_slide(Vector3(1, 0, 1) * 2, Vector3.UP)
	health = max_health;
	add_to_group("enemy")
	rng.randomize()
	move(null)

func destroy():
	var death_animation = preload("res://Scenes/Enemy_death.tscn").instance()
	death_animation.transform.origin = transform.origin
	get_parent().add_child(death_animation)
	call_deferred("queue_free")

func move(player):
	player_instance = player;
	var randomIndex = rng.randi_range(0, directions.size() - 1)
	var next_step = directions[randomIndex]
	if (engaging):
		var step = transform.origin.direction_to(player.transform.origin).normalized()
		next_step = Vector3(round(step.x), 0, 0) if (abs(step.x) > abs(step.z)) else Vector3(0, 0, round(step.z))

	var col = move_and_collide(next_step * tile_size, true, true, true);
	if (col && engaging && col.collider.name == "Player"):
		var dmg = hit_die[0] * hit_die[1] + attack_power;
		player_instance.take_damage(dmg)
	else:
		var _col = move_and_collide(next_step * tile_size);
	
func take_damage(dmg):
	health -= dmg
	engaging = true;
	$Blood.emitting = true;
	$Healthbar3D.update(health, max_health)
	if (health <= 0):
		destroy()
