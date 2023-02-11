extends KinematicBody

var moving = false;
var tile_size = 2;
var max_health = 100;
var health;
var directions = [Vector3.RIGHT,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK]
var rng = RandomNumberGenerator.new()

func _ready():
	health = max_health;
	add_to_group("enemy")
	rng.randomize()
	move_and_slide_with_snap(Vector3.ONE * tile_size + Vector3.ONE * tile_size/2, Vector3.ZERO)

func destroy():
	var death_animation = preload("res://Scenes/Enemy_death.tscn").instance()
	get_parent().add_child(death_animation)
	death_animation.global_transform.origin = global_transform.origin
	queue_free()

func move():
	var randomIndex = rng.randi_range(0, directions.size() - 1)
	var nextStep = directions[randomIndex] * tile_size * 60;
	var snap = Vector3.DOWN * tile_size 
	move_and_slide_with_snap(nextStep, snap)
	
func take_damage(dmg):
	health -= dmg
	$Blood.emitting = true;
	$Healthbar3D.update(health, max_health)
	if (health <= 0):
		destroy()
