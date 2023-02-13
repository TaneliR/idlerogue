extends KinematicBody

var moving = false;
var tile_size = 1;
var attack_power = 3;
var hit_die = [3, 6]; # 3d6+3
var health
var max_health = 140
var regen_rate = 2
var regen_tick
var regen_amount = 5

var rng = RandomNumberGenerator.new()
var inputs = {"right": Vector3.RIGHT,
			"left": Vector3.LEFT,
			"up": Vector3.FORWARD,
			"down": Vector3.BACK}
var inventory = []
onready var money = 0
signal money_changed
signal set_camera_target
signal update_health
const coin_type = preload("res://Scripts/Coins.gd")
const fog_type = preload("res://Scenes/FogOfWarMesh.tscn")

func _ready():
	var _move = move_and_slide(Vector3(.5, .5, .5), Vector3.UP)
	regen_tick = regen_rate;
	health = max_health;
	emit_signal("update_health", max_health);
	call_deferred("initialize_camera")
	rng.randomize()
	
func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir) && !moving:
			move(dir)

func move(dir):
	health_regen()
	var nextStep = inputs[dir] * tile_size;
	var col = move_and_collide(nextStep, true, true, true);
	if (col && col.collider.is_in_group("enemy")):
		attack(col.collider)
	else:
		var _col = move_and_collide(nextStep);
	if $PickupZone.items_in_range.size() > 0:
		var pickup_item = $PickupZone.items_in_range.values()[0]
		pickup_item.pick_up_item(self)
		if (pickup_item is coin_type):
			money = money + pickup_item.amount
			emit_signal("money_changed", money)
			$PickupZone.items_in_range.erase(pickup_item)
	get_tree().call_group("enemy", "move", self)
					
func attack(target):
	var dmg = hit_die[0] * hit_die[1] + attack_power;
	target.take_damage(dmg);

func take_damage(dmg):
	health -= dmg
	$Healthbar3D.update(health, max_health)
	emit_signal("update_health", health);
	if (health <= 0):
		print("WHAT? YOU SHOULD BE DEAD, CHEATER!")

func health_regen():
	regen_tick -= 1;
	if (regen_tick <= 0):
		health += regen_amount
		if (health > max_health):
			health = max_health
		emit_signal("update_health", health);
		regen_tick = regen_rate

func initialize_camera():
	emit_signal("set_camera_target", self)

func _on_SightArea_body_entered(body:Node):
	body.get_parent().change_to_visited()

func _on_SightArea_area_entered(area:Area):
	area.get_parent().get_parent().free()
