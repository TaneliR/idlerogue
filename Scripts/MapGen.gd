extends GridMap

enum TILE_TYPES {FLOOR, WALL}

onready var noise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var player_instance
var fog_nodes = []
export (int) onready var enemy_count
onready var allowed_spawn_points = []
export (int) onready var map_size
export (int) onready var map_height
export (int) onready var currentSeed
export (int) onready var noise_octaves
export (float) onready var noise_period
export (float) onready var noise_persistence
onready var offset_from_origin = Vector3(0, 0, 0)

onready var player = preload("res://Scenes/Player.tscn")
onready var enemy = preload("res://Scenes/Enemy.tscn")
onready var fog = preload("res://Scenes/FogOfWarMesh.tscn")
onready var marker = get_node("Marker")

signal move_camera
signal mapgen_finished

func _ready():
	rng.randomize()
	generate_new_map()
	
func generate_new_map():
	cleanup_map()
	# Generate the map as grid tiles
	for x in range(map_size):
		for z in range(map_size):
			var tileType = TILE_TYPES.WALL
			if 0.07 < noise.get_noise_2d(x,z):
				tileType = TILE_TYPES.FLOOR
				allowed_spawn_points.append(Vector3(x,0,z))
			# Add Fog of War
			add_fog_node(Vector3(x, 0, z))	
			set_cell_item(x,0,z,tileType)
	# Generate walls around the map
	for i in range(map_size):
		set_cell_item(-1, 0, i, TILE_TYPES.WALL)
		set_cell_item(map_size, 0, i, TILE_TYPES.WALL)
		set_cell_item(i, 0, -1, TILE_TYPES.WALL)
		set_cell_item(i, 0, map_size , TILE_TYPES.WALL)
	# Emit signals for AStar to start generating navigation,
	# and for the MapGen camera to move according to the new map size
	emit_signal("mapgen_finished", allowed_spawn_points)
	emit_signal("move_camera", map_size)
	populate_map()
	

func add_fog_node(pos: Vector3):
	var fog_instance = fog.instance()
	fog_instance.transform.origin = pos
	fog_nodes.append(fog_instance)
	add_child(fog_instance)
	
	
func populate_map():
	for _i in range(enemy_count):
		var random_spawn_point = allowed_spawn_points.pop_at(rng.randi_range(0, allowed_spawn_points.size()-1))
		var enemy_instance = enemy.instance()
		if random_spawn_point:
			enemy_instance.transform.origin = offset_from_origin + random_spawn_point
			add_child(enemy_instance)
	spawn_player()


func cleanup_map():
	clear()
	if (fog_nodes.size() > 0):
		for fog_node in fog_nodes:
			fog_node.queue_free()
	if (player_instance):
		player_instance.queue_free()
	var enemies = get_tree().get_nodes_in_group("enemy")
	if (enemies.size() > 0):
		for present_enemy in enemies:
			present_enemy.queue_free()
	noise.seed = currentSeed
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence
	allowed_spawn_points = []

func spawn_player():
	var random_spawn_point = allowed_spawn_points.pop_at(rng.randi_range(0, allowed_spawn_points.size()-1))
	player_instance = player.instance()
	if random_spawn_point:
		player_instance.transform.origin = offset_from_origin + random_spawn_point
		marker.transform.origin = random_spawn_point
		add_child(player_instance)
	$PlayerCamera.set_target(marker.get_node("CameraAnchor"))
	$PlayerCamera.make_current()

func _on_GenerateMap_button_down():
	print("EYYYYY")
	currentSeed = rng.randi()
	generate_new_map()

func _on_MapSize_value_changed(value):
	map_size = value as int

func _on_MapHeight_value_changed(value):
	map_height = value as int

func _on_NoiseOctaves_value_changed(value):
	noise_octaves = value as int

func _on_NoisePeriod_value_changed(value):
	noise_period = value

func _on_NoisePersistence_value_changed(value):
	noise_persistence = value
