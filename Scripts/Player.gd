extends KinematicBody

var moving = false;
var tile_size = 2;
var attack_power = 3;
var hit_die = [3, 6]; # 3d6+3
var rng = RandomNumberGenerator.new()
var inputs = {"right": Vector3.RIGHT,
			"left": Vector3.LEFT,
			"up": Vector3.FORWARD,
			"down": Vector3.BACK}
var inventory = []
onready var money = 0
signal money_changed
const coin_type = preload("res://Scripts/Coins.gd")

func _ready():
	rng.randomize()
	move_and_slide_with_snap(Vector3.ONE * tile_size + Vector3.ONE * tile_size/2, Vector3.ZERO)
	
func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir) && !moving:
			move(dir)

func move(dir):
	var nextStep = inputs[dir] * tile_size;
	get_tree().call_group("enemy", "move")
	var col = move_and_collide(nextStep, true, true, false);
	if (col):
		if (col.collider.is_in_group("enemy")):
			attack(col.collider)
	if $PickupZone.items_in_range.size() > 0:
		var pickup_item = $PickupZone.items_in_range.values()[0]
		pickup_item.pick_up_item(self)
		if (pickup_item is coin_type):
			money = money + pickup_item.amount
			emit_signal("money_changed", money)
		$PickupZone.items_in_range.erase(pickup_item)
	
func attack(target):
	var dmg = hit_die[0] * hit_die[1] + attack_power;
	target.take_damage(dmg);
	
