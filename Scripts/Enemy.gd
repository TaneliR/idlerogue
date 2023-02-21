extends KinematicBody

var info_name = "Rat"
var level = 1;
onready var info_image = $AnimatedSprite3D.frames
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
onready var move_sound = preload("res://Assets/SFX/rat_walk.wav")
onready var hit_sound = preload("res://Assets/SFX/rat_hit.wav")
var current_target;

signal end_turn;

func _ready():
	var _move = move_and_slide(Vector3(.5, .5, .5), Vector3.UP)
	# var _move = move_and_slide(Vector3(1, 0, 1) * 2, Vector3.UP)
	health = max_health;
	add_to_group("enemy")
#	TickManager.connect("tick", self, "_on_Tick")
	TickManager.connect("queue_action", self, "_on_Queue_action")
	$AnimationPlayer.set_current_animation("move")
	rng.randomize()
	var action = {"target": self, "time": speed}
	TickManager.queue(action)

func _on_Queue_action():
	var action = {"target": self, "time": speed}
	TickManager.queue(action)

func act():
	moving = true
	move(current_target)
	$SFX.stream = move_sound
	$SFX.play()
	$AnimationPlayer.set_current_animation("move")
	$AnimationPlayer.play()
	
func get_info():
	return {
		"name": info_name,
		"level": level,
		"image": info_image,
		"hp": health,
		"target": self
	}
	
	
func destroy():
	var death_animation = preload("res://Scenes/Enemy_death.tscn").instance()
	death_animation.transform.origin = transform.origin
	get_parent().add_child(death_animation)
	call_deferred("queue_free")

func move(player):
	current_target = player;
	var randomIndex = rng.randi_range(0, directions.size() - 1)
	var next_step = directions[randomIndex]
	if (engaging && player):
		look_at(transform.origin + global_transform.origin.direction_to(current_target.transform.origin).normalized(), Vector3.UP)
		var step = transform.origin.direction_to(player.transform.origin).normalized()
		next_step = Vector3(round(step.x), 0, 0) if (abs(step.x) > abs(step.z)) else Vector3(0, 0, round(step.z))

	var col = move_and_collide(next_step * tile_size);
	if (col && engaging && col.collider.name == "Player"):
		
		var dmg = hit_die[0] * rng.randi_range(1, hit_die[1]) + attack_power;
		current_target.take_damage(dmg)
		$AnimationPlayer.set_current_animation("attack")
		$AnimationPlayer.play()
		var attack_string = "hit player for [shake rate=55 level=15][color=red]%s[/color][/shake] [code][color=gray](%sd%s+%s)[/color][/code] damage." % [dmg, hit_die[0], hit_die[1], attack_power]
		
		TickManager.send_log_entry(self.info_name, attack_string)
	else:
		var _col = move_and_collide(next_step * tile_size);


func take_damage(dmg, from):
	current_target = from
	health -= dmg
	engaging = true;
	$Blood.emitting = true;
	$Healthbar3D.update(health, max_health)
	$SFX.stream = hit_sound
	$SFX.play()
	$AnimationPlayer.set_current_animation("hit")
	$AnimationPlayer.play()
	if (health <= 0):
		destroy()
