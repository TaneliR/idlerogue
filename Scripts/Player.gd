extends KinematicBody

onready var marker = get_parent().get_node("Marker")
onready var nav = get_parent().get_node("AStar")
var path := []
var current_target := Vector3.INF
var current_look_target := Vector3.INF
var current_velocity := Vector3.ZERO
var speed := 2
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
var inputs = {
			"right": Vector3.RIGHT,
			"left": Vector3.LEFT,
			"up": Vector3.FORWARD,
			"down": Vector3.BACK,
			"upleft": Vector3.LEFT + Vector3.FORWARD,
			"upright": Vector3.RIGHT + Vector3.FORWARD,
			"downleft": Vector3.LEFT + Vector3.BACK,
			"downright": Vector3.RIGHT + Vector3.BACK,
			}
var inventory = []
onready var info_name = "Player"
onready var money = 0
onready var can_move = true
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

func find_next_point_in_path():
	var action = { "target": self, "time": path.size() * speed}
	while !path.empty():
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		current_target = new_target
		
		print("Minä:", global_transform.origin)
		print("Path:", path)
		print("Pathpoint:", new_target)
		
		yield(get_tree().create_timer(0.5), "timeout")
		var dir = global_transform.origin.direction_to(new_target).normalized()
		print("Direction:", dir)
		var nextStep = Vector3(stepify(dir.x, tile_size), 0, stepify(dir.z, tile_size))
		print("what?")
		look_at(dir, Vector3.UP)
		var col = move_and_collide(nextStep);
#			move(new_target)
	can_move = false;
	TickManager.emit_signal("tick", action.time, self)	
		
#	else:
#		current_target = Vector3.INF

func tick_completed():
	can_move = true;

func update_path(new_path: Array):
	path = new_path
	path.remove(0)
	find_next_point_in_path()
	
func act():
	print("E")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !can_move:
			print("Can't move yet!")
			return
		var e: InputEventMouseButton = event
		var result = _raycast_from_camera_to_ground(e)
		if result != null and not result.empty():
			var stepified = Vector3(stepify(result.position.x, 1), 0 ,stepify(result.position.z, 1))
			var closest_astar_id = nav.astar.get_closest_point(stepified)
			var closest_center = nav.astar.get_point_position(closest_astar_id)
			current_look_target = closest_center
			if event.is_action_pressed("click"):
				if result.collider.is_in_group("pathable"):
					update_path(nav.find_path(transform.origin, closest_center))
					marker.global_transform.origin = closest_center
				elif result.collider.is_in_group("enemy"):
					var info = result.collider.get_info()
					InfoEventManager.emit_signal("show_infobox", info)
			elif event.is_action_pressed("right_click"):
				var new_spell = spell.instance()
				var spawn_point = transform.origin + Vector3(0,.5,0)
				new_spell.transform.origin = spawn_point
				var shoot_direction = spawn_point.direction_to(closest_center).normalized()
				get_parent().add_child(new_spell)
				new_spell.shoot(Vector3(shoot_direction.x, 0, shoot_direction.z), self)
				var action = { "target": self, "time": 1}
				TickManager.emit_signal("tick", action.time, self)
				
func _input(event):
	var action = null
	for _action in InputMap.get_actions():
		if InputMap.event_is_action(event, _action):
			action = _action
	if (inputs.has(action) and Input.is_action_just_pressed(action)):
		move(inputs[action])


func _raycast_from_camera_to_ground(event):
	var camera = get_parent().get_node("PlayerCamera")
	var from = camera.project_ray_origin(event.position);
	var to = from + camera.project_ray_normal(event.position) * 1000;
	var space_state = get_world().get_direct_space_state()
	return space_state.intersect_ray( from, to, [self], 5)

# /AStar

func move(dir):
	health_regen()
	var next_step = dir * tile_size;
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), 1);
	var col = move_and_collide(next_step);
	if (col && col.collider.is_in_group("enemy")):
		attack(col.collider)
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
	var attack_string = "hit [color=red]%s[/color] for [shake rate=1 level=10][color=red]%s[/color][/shake] [code][color=gray](%sd%s+%s)[/color][/code] damage." % [target.info_name, dmg, hit_die[0], hit_die[1], attack_power]
	TickManager.send_log_entry("[color=green]Player[/color]", attack_string)
	target.take_damage(dmg);7

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
