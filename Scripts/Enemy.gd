extends KinematicBody

var tile_size = 2;
var max_health = 100;
var attack_power = 1;
var hit_die = [2, 4]; # 2d4+1
var health;
var speed = 1;
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
#	TickManager.connect("tick", self, "_on_Tick")
	TickManager.connect("queue_action", self, "_on_Queue_action")
	$AnimationPlayer.set_current_animation("hit")
	rng.randomize()
	var action = {"target": self, "time": speed}
	TickManager.queue(action)

#func _on_Tick(_act_speed):
#	var action = {"target": self, "time": speed}
#	TickManager.emit_signal("queue_action", action)

func _on_Queue_action():
	var action = {"target": self, "time": speed}
	TickManager.queue(action)

func act():
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
	if (engaging && player):
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
	$AnimationPlayer.play()
	if (health <= 0):
		destroy()
