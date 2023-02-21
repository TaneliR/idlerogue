extends KinematicBody

class_name Entity

var speed: float
var max_health: int
var attack_power: int
var hit_die: Array
var health: int
var directions: Array
var tile_size: float

var rng = RandomNumberGenerator.new()
var engaging = false;
var moving = false;
var can_move = true;
var player_instance;
var current_target = Vector3.ZERO;
var current_velocity = Vector3.ZERO;
var path;

func _init(
		max_health := 100, 
		health := max_health, 
		speed := 2.0, 
		attack_power := 100, 
		hit_die := [2,4], 
		directions := [
			Vector3.RIGHT,
			Vector3.LEFT,
			Vector3.FORWARD,
			Vector3.BACK
			]
		):
	self.max_health = max_health
	self.health = health
	self.speed = speed
	self.attack_power = attack_power
	self.hit_die = hit_die
	self.directions = directions
	
	
# AStar
func _physics_process(delta: float) -> void:
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 12.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		look_at(transform.origin + global_transform.origin.direction_to(current_target).normalized(), Vector3.UP)

		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.1:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
	current_velocity = move_and_slide(new_velocity)
	
	
func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
		var action = { "target": self, "time": path.size() * speed}
		can_move = false;
		if (self == player_instance):
			TickManager.emit_signal("tick", action.time, self)
	else:
		current_target = Vector3.INF

func update_path(new_path: Array):
	path = new_path
	find_next_point_in_path()
