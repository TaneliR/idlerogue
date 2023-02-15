extends KinematicBody

onready var marker = get_parent().get_node("Marker")
onready var nav = get_parent().get_node("AStar")
var path := []
var current_target := Vector3.INF
var current_look_target := Vector3.INF
var current_velocity := Vector3.ZERO
var speed := 5.0
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

var spell = preload("res://Scenes/Spell3.tscn")
var spell_body = KinematicBody.new()
var spell_mesh = MeshInstance.new()

func _ready():
	var _move = move_and_slide(Vector3(.5, .5, .5), Vector3.UP)
	regen_tick = regen_rate;
	health = max_health;
	emit_signal("update_health", max_health);
	call_deferred("initialize_camera")
	rng.randomize()
	

# AStar
func _physics_process(delta: float) -> void:
	var new_velocity := Vector3.ZERO
	var lerp_weight = delta * 8.0
	if current_target != Vector3.INF:
		var dir_to_target = global_transform.origin.direction_to(current_target).normalized()
		look_at(transform.origin + global_transform.origin.direction_to(current_look_target).normalized(), Vector3.UP)

		new_velocity = lerp(current_velocity, speed * dir_to_target, lerp_weight)
		if global_transform.origin.distance_to(current_target) < 0.5:
			find_next_point_in_path()
	else:
		new_velocity = lerp(current_velocity, Vector3.ZERO, lerp_weight)
	current_velocity = move_and_slide(new_velocity)

func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
	else:
		current_target = Vector3.INF

func update_path(new_path: Array):
	path = new_path
	find_next_point_in_path()

# func _unhandled_input(event):
# 	for dir in inputs.keys():
# 		if event.is_action_pressed(dir) && !moving:
# 			move(dir)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event
		var camera = get_parent().get_node("PlayerCamera")
		var from = camera.project_ray_origin(e.position)
		var to = camera.project_ray_normal(e.position) * 1000

		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [marker, self])
		if result != null and not result.empty() and result.collider.is_in_group("pathable"):
			var closest_center = nav.astar.get_point_position(nav.astar.get_closest_point(result.position))
			current_look_target = closest_center
			if event.is_action_pressed("click"):
				update_path(nav.find_path(transform.origin, result.position))
				marker.global_transform.origin = closest_center
			elif event.is_action_pressed("right_click"):
				var new_spell = spell.instance()
				var spawn_point = transform.origin + Vector3(0,.5,0)
				new_spell.transform.origin = spawn_point
				var shoot_direction = spawn_point.direction_to(closest_center).normalized()
				print(shoot_direction)
				print(closest_center)
				get_parent().add_child(new_spell)
				new_spell.shoot(Vector3(shoot_direction.x, 0, shoot_direction.z))

# /AStar

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
	emit_signal("set_camera_target", marker)

func _on_SightArea_body_entered(body:Node):
	body.get_parent().change_to_visited()

func _on_SightArea_area_entered(area:Area):
	area.get_parent().get_parent().free()
