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
var player_instance;


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
	
