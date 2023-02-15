extends MeshInstance
onready var camera = get_parent().get_node("PlayerCamera")
onready var nav = get_parent().get_node("AStar")
onready var selector_mesh = preload("res://Scenes/CursorSelectorMeshDefault.tres")
var current_path_parent

func _input(event):
	if (event is InputEventMouseMotion):
		var result = raycast_from_camera_to_ground(event)
		
		if result && result.collider.is_in_group("pathable"):
			clear_old_path()
			var result_position = nav.astar.get_point_position(nav.astar.get_closest_point(result.position));
			global_transform.origin = result_position
			var path_to_player = nav.find_path(result_position, get_parent().get_node("Player").transform.origin)
			generate_path(path_to_player)

func raycast_from_camera_to_ground(event):
	var from = camera.project_ray_origin(event.position);
	var to = from + camera.project_ray_normal(event.position) * 1000;
	var space_state = get_world().get_direct_space_state()
	return space_state.intersect_ray( from, to )

func clear_old_path():
	if current_path_parent:
		current_path_parent.free()

func generate_path(path):
	var new_path_parent = Spatial.new()
	current_path_parent = new_path_parent
	for point in path:
		var selector = MeshInstance.new()
		selector.mesh = selector_mesh
		selector.transform.origin = point
		new_path_parent.add_child(selector)
	get_parent().add_child(new_path_parent)
