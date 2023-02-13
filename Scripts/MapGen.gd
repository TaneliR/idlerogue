extends GridMap

enum TILE_TYPES {FLOOR, WALL}

var noise := OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var player_instance
var fog_nodes = []

onready var allowed_spawn_points = [PoolVector3Array()]
onready var map_size = 36
onready var map_height = 2
onready var currentSeed
onready var noise_octaves = 3
onready var noise_period = 85.0
onready var noise_persistence = 0.85
onready var offset_from_origin = Vector3(.5, .5, .5)

onready var player = preload("res://Scenes/Player.tscn")
onready var enemy = preload("res://Scenes/Enemy.tscn")
onready var fog = preload("res://Scenes/FogOfWarMesh.tscn")

signal move_camera

func _ready():
	rng.randomize()
	currentSeed = rng.randi()
	generate_new_map()
	
func generate_new_map():
	emit_signal("move_camera", map_size)
	cleanup_map()
	for x in range(map_size):
		for z in range(map_size):
			var tileType = TILE_TYPES.WALL
			if 0.05 < noise.get_noise_2d(x,z):
				tileType = TILE_TYPES.FLOOR
				allowed_spawn_points.append(Vector3(x,0,z))
			var fog_instance = fog.instance()
			fog_instance.transform.origin = Vector3(x,0,z)
			fog_nodes.append(fog_instance)
			add_child(fog_instance)	
			set_cell_item(x,0,z,tileType)
	for i in range(map_size):
		set_cell_item(-1, 0, i, TILE_TYPES.WALL)
		set_cell_item(map_size, 0, i, TILE_TYPES.WALL)
		set_cell_item(i, 0, -1, TILE_TYPES.WALL)
		set_cell_item(i, 0, map_size , TILE_TYPES.WALL)
	populate_map()
	spawn_player()

func populate_map():
	for _i in range(int(map_size / 4)):
		var random_spawn_point = allowed_spawn_points.pop_at(rng.randi_range(0, allowed_spawn_points.size()-1))
		var enemy_instance = enemy.instance()
		enemy_instance.transform.origin = offset_from_origin + random_spawn_point as Vector3
		add_child(enemy_instance)


func cleanup_map():
	clear()
	if (fog_nodes.size() > 0):
		for fog_node in fog_nodes:
			fog_node.queue_free()
	if (player_instance):
		player_instance.queue_free()
	noise.seed = currentSeed
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence
	allowed_spawn_points = [PoolVector3Array()]

func spawn_player():
	var random_spawn_point = allowed_spawn_points.pop_at(rng.randi_range(0, allowed_spawn_points.size()-1))
	player_instance = player.instance()
	player_instance.transform.origin = offset_from_origin + random_spawn_point as Vector3
	add_child(player_instance)
	$PlayerCamera.set_target(player_instance.get_node("CameraAnchor"))
	$PlayerCamera.make_current()

func _on_GenerateMap_button_down():
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
