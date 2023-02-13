extends MeshInstance

onready var visited_mesh = preload("res://fog_mesh_visited.tres")
onready var default_mesh = preload("res://fog_mesh_dark.tres")
onready var surface_array = []



func _ready():
	pass
	# surface_array.resize(Mesh.ARRAY_MAX)

	# var verts = PoolVector3Array()
	# var uvs = PoolVector2Array()
	# var normals = PoolVector3Array()
	# var indices = PoolIntArray()

	# surface_array[Mesh.ARRAY_VERTEX] = verts
	# surface_array[Mesh.ARRAY_TEX_UV] = uvs
	# surface_array[Mesh.ARRAY_NORMAL] = normals
	# surface_array[Mesh.ARRAY_INDEX] = indices

	# mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array) 

func _on_Area_area_entered(area:Area):
	print(area)
	print("itefok")
	#self.queue_free()
	
	
func _on_Area_body_entered(body:Node):
	print("itefokbod")
	print(body)

func change_to_visited():
	mesh = visited_mesh
